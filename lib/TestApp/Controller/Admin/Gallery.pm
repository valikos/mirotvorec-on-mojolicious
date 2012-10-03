package TestApp::Controller::Admin::Gallery;

use strict;
use warnings;

use base 'Mojolicious::Controller';
use Mojo::ByteStream 'b';
use Mojo::Util qw`encode decode`;

use Data::Dumper;

# обработка статей
sub gallery {
    my $self = shift;

    my $page = $self->param('page') || '1';
    my $ac = $self->param('ac') || 'view';
    my $g_id = $self->param('g_id') || '0';

    $self->stash('ac'   => $ac);
    $self->stash('g_id' => $g_id);
    $self->stash('page' => $page);
    $self->stash('page_id' => 'gallery');

    # show list of gallery
    if ($ac eq 'view') {

        my $cc = TestApp::Model::Gallery->select('count(g_id)')->list;

        if ($cc > 0) {

            if ( ($cc / $ENV{ITEMS_ON_PAGE}) <= 1) {
                $self->stash('pages' => 0);
            } else {
                $self->stash('pages' => int($cc / $ENV{ITEMS_ON_PAGE}) + 1);
            }

            my $galls = TestApp::Model::Gallery->select()->hashes;

            if ($galls) {

            foreach my $it (@$galls) {
                decode ('cp-1251', $it->{'g_title'});
                decode ('cp-1251', $it->{'g_description'});
            } 
        
            $self->render(template => 'admin/gallery/preview',
                          'message' => 'Галереи',
                          'var' => $galls,
                          'err' => undef,
                         );
            return 1;
            }

        }
        $self->render(template => 'admin/gallery/preview',
                'message' => 'Галереи',
                'var' => undef,
                'err' => undef,
            );
        return 1;
    }

    # show album
    if ($ac eq 'album') {
        my $cc = TestApp::Model::Gallery->select('', "g_id='$g_id'")->list;

        if ($cc > 0) {
            my $album = TestApp::Model::Gallery->select('', "g_id='$g_id'")->hash;

            $self->render(template => 'admin/gallery/album',
                          'message' => b('Альбом')->decode('cp-1251'),
                          'var' => $album,
                          'err' => undef,
                         );
            return 1;

        } 
    }

    # edit gallery(album)
    if ($ac eq 'edit') {
    # edit or create gallery album
        my $new;

        my $cc = TestApp::Model::Gallery->select('count(g_id)', 'g_id=\''.$g_id.'\'', '')->list;

        if ($cc > 0) {

            my $photos;

            $new = TestApp::Model::Gallery->select('', 'g_id=\''.$g_id.'\'', '')->hash;

            decode 'cp-1251', $new->{'g_author'};
            decode 'cp-1251', $new->{'g_title'};
            decode 'cp-1251', $new->{'g_description'};

            $photos = TestApp::Model::Photos->select('', 'g_id=\''.$g_id.'\'', '')->hashes;
            $photos = undef unless $photos;
            warn Dumper $photos;

            $self->render(template => 'admin/gallery/album',
                          'message' => b('Редактировать альбом')->decode('cp-1251'),
                          'var' => $new,
                          'err' => undef,
                          'path' => $ENV{ORIG_IMG},
                          'photos' => $photos,
                         );
            return 1;
        }
            $self->render(template => 'admin/gallery/edit',
                          'message' => b('Добавить новый альбом')->decode('cp-1251'),
                          'var' => undef,
                          'err' => undef,
                         );
            return 1;
    }

    if ($ac eq 'album_update') {
    
    }

    if ($ac eq 'update') {
        my (%param, @err);

#        push @err, b('Не указано имя')->decode('cp-1251')
#            unless $self->param('a_author_name');
#        push @err, b('Не указан заголовок статьи')->decode('cp-1251')
#            unless $self->param('a_title');
#        push @err, b('Не указано описание статьи')->decode('cp-1251')
#            unless $self->param('a_description');

        if (@err) {

            warn Dumper 'Error';

            my @cols = TestApp::Model::Gallery->select()->columns;

            foreach (@cols) {
                $param{$_} = b($self->param($_))->decode('cp-1251');
            }

            $self->render(template => 'admin/gallery/edit',
                          'message' => b('Статьи')->decode('cp-1251'),
                          'var' => \%param,
                          'err' => \@err,
                         );
            return 1;
        }

        if ($g_id > 0) { # update
            my ($err, %param, $image);

    #        push @err, b('Не указано имя')->decode('cp-1251')
    #            unless $self->param('a_author_name');
    #        push @err, b('Не указан заголовок статьи')->decode('cp-1251')
    #            unless $self->param('a_title');
    #        push @err, b('Не указано описание статьи')->decode('cp-1251')
    #            unless $self->param('a_description');
    
            if (@err) {
    
                warn Dumper 'Error';
    
                my @cols = TestApp::Model::Gallery->select()->columns;
    
                foreach (@cols) {
                    $param{$_} = b($self->param($_))->decode('cp-1251');
                }
    
                $err = \@err;
            } else {
                $err = undef;
            }

            $param{'g_author_id'} = $self->param('g_author_id') || $self->stash('ADMIN')->{'u_id'};
            $param{'g_title'} = $self->param('g_title');
            $param{'g_description'} = $self->param('g_description');

            my $update = TestApp::Model::Gallery->update(\%param, {'g_id' => $g_id});        

            my $photos;

            my $new = TestApp::Model::Gallery->select('', 'g_id=\''.$g_id.'\'', '')->hash;

            decode 'cp-1251', $new->{'g_author'};
            decode 'cp-1251', $new->{'g_title'};
            decode 'cp-1251', $new->{'g_description'};

            $photos = TestApp::Model::Photos->select('', 'g_id=\''.$g_id.'\'', '')->hashes;
            $photos = undef unless $photos;

        if ($image = $self->req->upload('preview')) {
            
            my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime(time);
            $mon += 1;
            $year += 1900;
            my $scale = 0;

            my $image_name = sprintf('image-%04s%02s%02s%02s%02s%02s-%05d', $year, $mon, $mday, $hour, $min, $sec, int rand(10000));

            my $image_type = $image->headers->content_type;
            my %valid_types = map {$_ => 1} qw(image/gif image/jpeg image/png);

            # Extention
            my $exts = {'image/gif' => 'gif', 'image/jpeg' => 'jpg',
                    'image/png' => 'png'};
            my $ext = $exts->{$image_type};

            # save original image
            $image->move_to($ENV{TEMP_IMG} . $image_name . ".$ext");

            TestApp::Model->init_image();
    
            TestApp::Model::Image->optimize($image_name, $ext);

            TestApp::Model::Image->scale(200, $image_name . '.jpg');
            
            my $old_img = TestApp::Model::Gallery->select('g_cover', 'g_id=\''.$g_id.'\'')->list;

            if (-f $ENV{ORIG_IMG} . $old_img) {
                unlink $ENV{ORIG_IMG} . $old_img;
            }
            if (-f $ENV{SCALE_IMG} . $old_img) {
                unlink $ENV{SCALE_IMG} . $old_img;
            }

            TestApp::Model::Gallery->update({'g_cover' => $image_name . ".jpg"}, {'g_id' => $g_id});

        }
            $self->render(template => 'admin/gallery/album',
                          'message' => b('Редактировать альбом')->decode('cp-1251'),
                          'var' => $new,
                          'err' => $err,
                          'path' => $ENV{ORIG_IMG},
                          'photo' => $photos,
                         );
            return 1;

        } else { # create new album

            my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime(time);
            $mon += 1;
            $year += 1900;

            my @cols = TestApp::Model::Gallery->select()->columns;

            foreach (@cols) {
                $param{$_} = $self->param($_);
            }

            my $image_name = sprintf('image-%04s%02s%02s%02s%02s%02s-%05d', $year, $mon, $mday, $hour, $min, $sec, int rand(10000));

            my $image = $self->req->upload('preview');
            my $image_type = $image->headers->content_type;
            my %valid_types = map {$_ => 1} qw(image/gif image/jpeg image/png);

            # Extention
            my $exts = {'image/gif' => 'gif', 'image/jpeg' => 'jpg',
                    'image/png' => 'png'};
            my $ext = $exts->{$image_type};

            # save original image
            $image->move_to( $ENV{MOJO_TMPDIR} . $image_name . ".$ext" );

            TestApp::Model->init_image();
    
            TestApp::Model::Image->optimize($image_name, $ext);

            TestApp::Model::Image->scale(200, $image_name . '.jpg');

            $param{'g_id'}          = undef;
            $param{'g_create'}      = sprintf('%04d-%02d-%02d %02d:%02d:%02d', $year+1900, $mon+1, $mday, $hour, $min, $sec);
            $param{'g_cover'}       = $image_name . ".jpg";
            $param{'g_author_id'}   = $self->param('g_author_id') || $self->stash('ADMIN')->{u_id};
            $param{'g_title'}       = $self->param('g_title');
            $param{'g_description'} = $self->param('g_description');
            $param{'g_comments'}    = 0;
            $param{'g_previews'}    = 0;

            my $row_id = TestApp::Model::Gallery->insert(\%param);

            warn Dumper ('insert', {'row_id' => $row_id});
        }
    
        $self->redirect_to('/admin/gallery');
    }

    if ($ac eq 'del') {

        # simple delete image
        # TODO more detail deleting images!!!

        my $img = TestApp::Model::Gallery->select('g_cover', 'g_id=\''.$self->param('g_id').'\'')->list;

        if ($img) {
            if (-f $ENV{ORIG_IMG} . $img) {
                unlink $ENV{ORIG_IMG} . $img;
            }
            if (-f $ENV{SCALE_IMG} . $img) {
                unlink $ENV{SCALE_IMG} . $img;
            }
        }

        my $photos;

        $photos = TestApp::Model::Photos->select('', 'g_id=\''.$self->param('g_id').'\'', '')->hashes;
        $photos = undef unless $photos;

        foreach (@$photos) {
            if (-f $ENV{ORIG_IMG} . $_->{'p_name'}) {
                unlink $ENV{ORIG_IMG} . $_->{'p_name'};
            }
            if (-f $ENV{SCALE_IMG} . $_->{'p_name'}) {
                unlink $ENV{SCALE_IMG} . $_->{'p_name'};
            }
        }

        my $del = '';
        $del = TestApp::Model::Gallery->delete(
                {'g_id' => $self->param('g_id')}
            );
        $del = '';
        $del = TestApp::Model::Photos->delete(
                {'g_id' => $self->param('g_id')}
            );
 
        $self->redirect_to('/admin/gallery');

    }

}

sub album_uploader {
    my $self = shift;

    my @images;
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime(time);
    # types
    my %valid_types = map {$_ => 1} qw(image/gif image/jpeg image/png);
    # Extention
    my $exts = {'image/gif' => 'gif', 'image/jpeg' => 'jpg', 'image/png' => 'png'};

    for (1..5) {
        push @images, $self->req->upload(qq`photo$_`) if $self->req->upload(qq`photo$_`);
    }

    if (scalar @images > 0) {
        foreach (@images) {

            my $image_name = sprintf('photo-%04s%02s%02s%02s%02s%02s-%05d', $year, $mon, $mday, $hour, $min, $sec, int rand(10000));

            my $image = $_; # $self->req->upload(qq`photo1`);
            my $image_type = $image->headers->content_type;

            my $ext = $exts->{$image_type};

            # save original image
            $image->move_to($ENV{TEMP_IMG} . $image_name . ".$ext");
            # save scle image
            TestApp::Model->init_image();
            TestApp::Model::Image->optimize($image_name . '.png');
            TestApp::Model::Image->scale(100, $image_name . '.png');
            # insert data to DB
            my %param;

            $param{'p_id'}          = undef;
            $param{'g_id'}          = $self->param('g_id');
            $param{'p_name'}        = $image_name . ".$ext";
            $param{'p_description'} = $image_name . ".$ext";
            TestApp::Model::Photos->insert(\%param);
        }
    }

    $self->redirect_to('/admin/gallery?ac=edit&page=1&g_id='.$self->param('g_id'));
}

1;
__END__