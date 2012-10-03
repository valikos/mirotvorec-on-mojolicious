package TestApp::Controller::Admin::Articles;

use strict;
use warnings;

use base 'Mojolicious::Controller';
use Mojo::ByteStream 'b';
use Mojo::Util qw`encode decode`;

use Data::Dumper;

__PACKAGE__->attr(conf => sub { do 'conf/text_massages.conf' });

# обработка новостей
sub articles {
    my $self = shift;

    # load config
    my $cfg = $self->conf;
    # decode config
    foreach (keys %$cfg){
        $cfg->{$_} = b($cfg->{$_})->decode('utf-8');
    }
    $self->stash('CFG' => $cfg);

    my $page = $self->param('page') || '1';
    my $ac = $self->param('ac') || 'view';
    my $a_id = $self->param('a_id') || '0';

    $self->stash('ac'   => $ac);
    $self->stash('a_id' => $a_id);
    $self->stash('page' => $page);
    $self->stash('page_id' => 'articles');

    # show articles
    if ($ac eq 'view') {
        my ($news, $cc);

        # limit on select query
        my %limit;
        $limit{'beg'} = ($page - 1) * $ENV{ITEMS_ON_PAGE};
        $limit{'end'} = $ENV{ITEMS_ON_PAGE};
        $limit{'str'} = 'LIMIT ' . $limit{'beg'} . ', ' . $limit{'end'};

        $cc = TestApp::Model::Articles->select('count(a_id)')->list;

        if ($cc > 0) {

            if ( ($cc / $ENV{ITEMS_ON_PAGE}) <= 1) {
                $self->stash('pages' => 0);
            } else {
                $self->stash('pages' => int($cc / $ENV{ITEMS_ON_PAGE}) + 1);
            }

            $news = TestApp::Model::Articles->select('','','a_id DESC ' . $limit{'str'})->hashes;

            if ($news) {
                foreach (@$news) {
                    my ($second, $minute, $hour, $mday, $month, $year) = localtime($_->{'a_create'});
                    $_->{'a_create'} = sprintf(
                        '%02d.%02d.%04d %02d:%02d',
                        $mday, $month+1, $year+1900, $hour, $minute
                    );
                }

            } else {
                $news = undef;
                $self->stash('pages' => 0);
            }

        } else {
            $self->stash('pages' => 0);
        }

        $self->render(template => 'admin/article/preview',
                'var' => $news,
                'err' => undef,
            );
        return 1;
    }

    # edit article
    if ($ac eq 'edit') {
        
        my ($new, $cc);

        $cc = TestApp::Model::Articles->select('count(a_id)', 'a_id=\''.$a_id.'\'', '')->list;

        if ($cc > 0) {
            # edit article
            $new = TestApp::Model::Articles->select('', 'a_id=\''.$a_id.'\'', '')->hash;
        } else {
            # add article
            $new = undef;
        }

            $self->render(template => 'admin/article/edit',
                          'var' => $new,
                          'err' => undef,
                         );
            return 1;

    }

    # update or create article
    if ($ac eq 'update') {

        my (%param, @err, $param);

        push @err, 'title' unless $self->param('a_title');
        push @err, 'description' unless $self->param('a_description');
        push @err, 'preview' unless $self->param('a_preview');

        my $article = TestApp::Model::Articles->select('', 'a_id=\''.$a_id.'\'', '')->hash;

        if ($article) {
            $param->{'a_title'} = $self->param('a_title');
            $param->{'a_description'} = $self->param('a_description');
            $param->{'a_preview'} = $self->param('a_preview');
            $self->stash('params' => $param);
        }

        if (@err) {

            my @cols = TestApp::Model::Articles->select()->columns;


            $self->render(template => 'admin/article/edit',
                          'var' => $article,
                          'err' => \@err,
                         );
            return 1;
        }

        if ($a_id > 0) {
            # update exist article
            my $p;
            my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime(time);

            if ($self->stash('ADMIN')->{u_id} eq $article->{a_u_id} || $self->stash('ADMIN')->{u_mode} eq  2) {
                $p = $self->param('a_publish') eq 1 ? 1 : 0;
            }

            $param{'a_publish'}     = $p if ($p =~ /1|0/);
            $param{'a_cat'}         = $self->param('a_cat');
            $param{'a_title'}       = $self->param('a_title');
            $param{'a_description'} = $self->param('a_description');
            $param{'a_preview'}     = $self->param('a_preview');
            $param{'a_update'}      = time; #sprintf('%04d-%02d-%02d %02d:%02d:%02d', $year+1900, $mon+1, $mday, $hour, $min, $sec);

            my $update = TestApp::Model::Articles->update(\%param, {'a_id' => $a_id});

            warn Dumper 'update';

        } else {
            # create new article

            my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime(time);

            my @cols = TestApp::Model::Articles->select()->columns;

            foreach (@cols) {
                $param{$_} = $self->param($_);
            }

            $param{'a_id'}       = undef;
            $param{'a_u_id'}     = $self->stash('ADMIN')->{u_id}; #int(rand(50));
            $param{'a_u_login'}  = $self->stash('ADMIN')->{u_login};
            $param{'a_create'}   = time; # sprintf('%04d-%02d-%02d  %02d:%02d', $year+1900, $mon+1, $mday, $hour, $min);
            $param{'a_update'}   = 0;
            $param{'a_comments'} = 0;
            $param{'a_previews'} = 0;
            $param{'a_publish'}  = 1;

            my $row_id = TestApp::Model::Articles->insert(\%param);

            warn Dumper ('insert', {'row_id' => $row_id});
        }

        $self->redirect_to('/admin/articles');
    }

    # delete article
    if ($ac eq 'del') {

        my $del = TestApp::Model::Articles->delete(
                {'a_id' => $self->param('a_id')}
            );

        $self->redirect_to('/admin/articles');

    }

}

1;