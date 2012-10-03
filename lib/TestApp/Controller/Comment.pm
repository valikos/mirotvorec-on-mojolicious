package TestApp::Controller::Comment;

use strict;
use warnings;

use base 'Mojolicious::Controller';
use Mojo::ByteStream 'b';
use Mojo::Util qw`decode encode html_unescape html_escape xml_escape`;

use Data::Dumper;

sub get_comment {
    my $self = shift;

    my $c_id = $self->stash('id');
    my ($cc, $comment);

    $cc = TestApp::Model::Comments->select('count(c_id)', 'c_id=\'' . $c_id . '\'', '')->list;

    if ($cc) {
        $comment = TestApp::Model::Comments->select('*', 'c_id=\'' . $c_id . '\'', '')->hash;
        $self->render({json => {data => $comment, code => '1'}});
    } else {
        $self->render({json => {code => '-1', satus => 'Comment not found'}});
    }
}

sub add_comment {
    my $self = shift;

    my $a_id = $self->stash('article_id');
    my ($comment, %var);

    my $cc = TestApp::Model::Articles->select('count(a_id)', 'a_id=\''.$a_id.'\'', '')->list;

    if ($cc > 0 && ( $self->param('c_comment') ne '' )) {
        
        # my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime(time);
        $var{'c_comment'}   = $self->param('c_comment');
        $var{'c_a_id'}      = $a_id;
        $var{'c_g_id'}      = q``;
        $var{'c_u_id'}      = $self->stash('USER')->{'u_id'};
        $var{'c_create'}    = time; #sprintf('%04d-%02d-%02d %02d:%02d', $year+1900, $mon+1, $mday, $hour, $min);
        $var{'c_update'}    = q``;

        TestApp::Model::Comments->insert(\%var);

    } else {
        $self->flash('empty_msg' => 1);
    }
    $self->redirect_to('/article/' . $a_id . '/');
}

sub add_comment_gal {
    my $self = shift;

    my $g_id = $self->stash('gallery_id');
    my ($comment, %var);

    my $cc = TestApp::Model::Gallery->select('count(g_id)', 'g_id=\''.$g_id.'\'', '')->list;

    if ($cc > 0 && ( $self->param('c_comment') ne '' )) {
        
        # my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime(time);
        $var{'c_comment'}   = $self->param('c_comment');
        $var{'c_a_id'}      = q``;
        $var{'c_g_id'}      = $g_id;
        $var{'c_u_id'}      = $self->stash('USER')->{'u_id'};
        $var{'c_create'}    = time; #sprintf('%04d-%02d-%02d %02d:%02d', $year+1900, $mon+1, $mday, $hour, $min);
        $var{'c_update'}    = q``;

        TestApp::Model::Comments->insert(\%var);

    } else {
        $self->flash('empty_msg' => 1);
    }
    $self->redirect_to('/gallery/preview/' . $g_id . '/');
}

sub update_comment {
    my $self = shift;
    
    # TODO add article or gallery id for more check
    TestApp::Model->init_bbcode();
    
    my ($c_id, $text, $comment, $user_id, $comment_id, $D);
    $c_id = $self->stash('c_id');
    $text = $self->param('c_comment');
    chomp $text;
    # check c_id
    $comment = TestApp::Model::Comments->select('', 'c_id=\''.$c_id.'\'', '')->hash;
    
    if ($comment && $text ne q'') {
        
        $user_id = $comment->{c_u_id};
        $comment_id = $comment->{c_id};
        if (
            ($self->stash('USER')->{u_id} eq $user_id && $self->stash('USER')->{u_mode} > 0)
            ||
            ($self->stash('USER')->{u_mode} eq 2 )
            ) {
            # update comment
            my $where = {
                'c_id' => $comment_id,
            };
            my $fieldvals = {
                'c_comment' => $text,
                'c_update' => time,
            };

            $fieldvals->{c_g_id} = q'' if ($comment->{c_a_id} && $comment->{c_a_id} ne q'');
            $fieldvals->{c_a_id} = q'' if ($comment->{c_g_id} && $comment->{c_g_id} ne q'');

            $D = TestApp::Model::Comments->update( $fieldvals, $where );

            $text = TestApp::Model::BBCode->pars_html($text);

            $self->render(json => {status => 1, c_id => $comment_id, text => $text});
            return 1;
        }
    }

    # warn Dumper ('Update', $c_id, $self->param('c_comment'));

    $self->render(json => {status => -1, c_id => $c_id});
}

sub delete_comment {
    my $self = shift;

    my $c_id = $self->stash('c_id');

    my $cc = TestApp::Model::Comments->select('count()','c_id=\''.$c_id.'\'')->list;

    if ($cc > 0) {

        my $com = TestApp::Model::Comments->select('*','c_id=\''.$c_id.'\'')->hash;

        if (
            ($com->{c_u_id} eq $self->stash('USER')->{'u_id'} && $self->stash('USER')->{'u_mode'} > 0)
            ||
            ($self->stash('USER')->{'u_mode'} eq 2)
            ) {
            my $del = TestApp::Model::Comments->delete(
                {'c_id' => $c_id}
            );
            $self->render(json => {status => '1'});
            return 1;
        } else {
            $self->render(json => {status => '-1'});
            return 1;
        }
    } else {
        $self->render(json => {status => '-1'});
        return 1;
    }
}

1;
__END__