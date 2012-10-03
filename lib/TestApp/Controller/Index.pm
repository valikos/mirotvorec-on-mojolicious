package TestApp::Controller::Index;

use strict;
use warnings;

use base 'Mojolicious::Controller';
use Mojo::ByteStream 'b';
use Mojo::Util qw`decode encode html_unescape html_escape`;

use Data::Dumper;

sub welcome {
    my $self = shift;

    TestApp::Model->init_bbcode();

    my ($db, %var, $page, %limit, $html);

    $page = $self->stash('num');
    $self->stash('page' => $page);

    $limit{'beg'} = ($page - 1) * $ENV{ITEMS_ON_PAGE};
    $limit{'end'} = $ENV{ITEMS_ON_PAGE};
    $limit{'str'} = 'LIMIT ' . $limit{'beg'} . ', ' . $limit{'end'};

    # считывает призраков по лимиту

    my $cc = TestApp::Model::Articles->select('count(a_id)', 'a_publish=1')->list;

    if ($cc > 0) {

        if ( ($cc / $ENV{ITEMS_ON_PAGE}) <= 1) {
            $self->stash('pages' => 0);
        } else {
            $self->stash('pages' => int($cc / $ENV{ITEMS_ON_PAGE}) + 1);
        }

        $html = TestApp::Model::Articles->select('*', 'a_publish=1', 'a_id DESC ' . $limit{'str'})->hashes;

        if ($html) {
            # date traslate
            foreach my $it (@$html) {
                my ($second, $minute, $hour, $mday, $month, $year, $wday) = localtime($it->{'a_create'});
                $it->{'a_create'} = sprintf(
                    '%02d.%02d.%04d %02d:%02d',
                    $mday, $month+1, $year+1900, $hour, $minute
                );
            }
        } else {
            $html = '';
        }

    } else {
        $self->stash('pages' => 0);
        $html = '';
    }

    $self->render(var => $html);
}

sub detail {
    # TODO quote eskape
    
    my $self = shift;

    TestApp::Model->init_bbcode();

    my ($count, $html, $a_id, $mes);

    $a_id = $self->stash('id');

    my $cc = TestApp::Model::Articles->select('count(a_id)', 'a_id=\''.$a_id.'\'', '')->list;

    if ($cc > 0) {
            # increment previews
            $count = TestApp::Model::Articles->select('a_previews', 'a_id=\''.$a_id.'\'', '')->list;
            TestApp::Model::Articles->update({'a_previews' => $count+1}, {'a_id' => $a_id});        
            # update previews count
            $html = TestApp::Model::Articles->select('', 'a_id=\''.$a_id.'\'', '')->hash;
            
            $mes = $html->{'a_title'};
    } else {
        $html = undef;
    }
    
    # get comments
    my $comments;
    
    $cc = TestApp::Model::Comments->select('count(c_id)', 'c_a_id=\'' . $a_id . '\'', '')->list;
    
    if ($cc > 0) {
        $comments = TestApp::Model::Base->select_join(
            'comments as c, articles as a, users as u',
            'c.*, u.u_login, u.u_avatar', 
            'c.c_u_id=u.u_id and c.c_a_id=a.a_id and c.c_a_id=\''.$a_id.'\'', 
            'c.c_id'
        )->hashes;

        foreach (@$comments) {
            html_unescape $_->{'c_comment'} if $_->{'c_comment'};
            $_->{'c_comment'} = TestApp::Model::BBCode->pars_html($_->{'c_comment'}); # if $_->{'c_comment'};
            my ($second, $minute, $hour, $mday, $month, $year, $wday) = localtime($_->{'c_create'});
            $_->{'c_create'} = sprintf(
                '%02d.%02d.%04d %02d:%02d',
                $mday, $month+1, $year+1900, $hour, $minute
            );
        }

    } else {
        $comments = undef;
    }

    $self->render(
                'message' => $mes,
                'var' => $html || undef,
                'comments' => $comments,
    );

    return 1;
}

sub add_comment {
    my $self = shift;

    my $a_id = $self->stash('id');
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

# get comment for edit
# return bbcode format description
sub get_comment_edit{
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

sub rules () {
    my $self = shift;

    $self->render();
}

#editor demonstration
sub demo () {
    my $self = shift;

    $self->render();
}

1;
__END__