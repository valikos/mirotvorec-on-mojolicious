package TestApp::Controller::Personal;

use strict;
use warnings;

use base 'Mojolicious::Controller';

use Mojo::ByteStream 'b';
use Mojo::Util qw/decode encode html_escape html_unescape/;

use Data::Dumper;

# get user info
sub get_info {
    my $self = shift;

    my $user = $self->stash('user') || $self->stash('USER')->{u_login};
    my $cc = TestApp::Model::Users->select('count()', 'u_login=\''.$user.'\'')->list;

    if ($cc > 0) {
        $user = TestApp::Model::Users->select(
                '*', 
                'u_login=\'' . $user . '\''
            )->hash;
        # $user->{u_about} =~ s/\n+\r?/<br \/>/ if $user->{u_about};
        $user->{'u_about'} =~ s/(:?\r)?\n/<br \/>/ig if $user->{u_about};
    } else {
        $user = '';
    }

    $self->render(err => '', 'personal' => $user);
    return 1;
}

# edit user info
sub get_edit_info {
    my $self = shift;

    my $user = $self->stash('USER') ? $self->stash('USER')->{'u_login'} : '';
    my $cc = TestApp::Model::Users->select('count()','u_login=\'' . $user . '\'')->list;

    if ($cc > 0) {
        $user = TestApp::Model::Users->select('*','u_login=\'' . $user . '\'')->hash;
    } else {
        $user = '';
    }
    $self->render(err => '', 'var' => $user);
}
# update user info
sub update_info {
    my $self = shift;

    my ($info, %param, $image);

    $info = TestApp::Model::Users->select(
                '*', 
                'u_user_session=\'' . $self->session('user_id') . '\''
            )->hash;

    if ($info) {
        my $about = $self->param('u_about');
        html_escape $about;

        $param{u_about} = $about || '';
        $param{u_name}  = $self->param('u_name')  || '';
        $param{u_sname} = $self->param('u_sname') || '';
        $param{u_fname} = $self->param('u_fname') || '';
        $param{u_tel}   = $self->param('u_tel')   || '';
        $param{u_icq}   = $self->param('u_icq')   || '';
        $param{u_skype} = $self->param('u_skype') || '';

        # update info data
        my $update = TestApp::Model::Users->update(\%param, {'u_user_session' => $self->session('user_id')});
        
        # update avatar
        if ($image = $self->req->upload('u_avatar')) {
            my ($sec,$min,$hour,$mday,$mon,$year)=localtime(time);
            my $scale = 0;
            my $old_avatar = TestApp::Model::Users->select('u_avatar', 'u_user_session=\'' . $self->session('user_id') . '\'')->list;

            my $image_name = sprintf('ava-%04s%02s%02s%02s%02s%02s-%05d', $year+1900, $mon+1, $mday, $hour, $min, $sec, int rand(10000));

            my $image_type = $image->headers->content_type;
            my %valid_types = map {$_ => 1} qw(image/gif image/jpeg image/png);

            # Extention
            my $exts = {'image/gif' => 'gif', 'image/jpeg' => 'jpg',
                    'image/png' => 'png'};
            my $ext = $exts->{$image_type};

            # save original image
            $image->move_to($ENV{AVATAR_IMG} . 'tmp-' . $image_name . ".$ext");

            TestApp::Model->init_image();
            $scale = TestApp::Model::Image->ava_scale($image_name . ".$ext") if -f $ENV{AVATAR_IMG} . 'tmp-' . $image_name . ".$ext";

            if ($scale > 0) {
                TestApp::Model::Users->update({u_avatar => '/images/avatar/' . $image_name . ".$ext"}, {'u_user_session' => $self->session('user_id')});            
            } else {
                TestApp::Model::Users->update({u_avatar => ''}, {'u_user_session' => $self->session('user_id')});
            }
            # delete temp image
            unlink ($ENV{AVATAR_IMG} . 'tmp-' . $image_name . ".$ext") if -e $ENV{AVATAR_IMG} . 'tmp-' . $image_name . ".$ext";
            # delete prefix slash
            $old_avatar =~ s/^\///io;
            # delete old image
            unlink ($ENV{PUBLIC_DIR} . $old_avatar) if -e $ENV{PUBLIC_DIR} . $old_avatar;
        }
        $self->redirect_to('/user');
    }
    $self->redirect_to('/user');
}

# ###############################
sub gallery {
    my $self = shift;

    my $gal;

    my $user_id = $self->stash('USER')->{'u_id'};

    my $page = $self->param('page') || '1';
    my $ac = $self->param('ac') || 'view';
    my $g_id = $self->param('g_id') || '0';

    $self->stash('ac'   => $ac);
    $self->stash('g_id' => $g_id);
    $self->stash('page' => $page);
    $self->stash('page_id' => 'gallery');

        my $cc = TestApp::Model::Gallery->select('count(g_id)', 'g_author_id=\'' . $user_id. '\'')->list;

        if ($cc > 0) {

#            if ( ($cc / $ENV{ITEMS_ON_PAGE}) <= 1) {
#                $self->stash('pages' => 0);
#            } else {
#                $self->stash('pages' => int($cc / $ENV{ITEMS_ON_PAGE}) + 1);
#            }

            my $gal = TestApp::Model::Gallery->select('', 'g_author_id=\'' . $user_id. '\'')->hashes;

            if ($gal) {

            foreach my $it (@$gal) {
                decode ('cp-1251', $it->{'g_title'});
                decode ('cp-1251', $it->{'g_description'});
            } 
        
            $self->render(template => 'personal/gallery/preview',
                          'message' => b('Галерея')->decode('cp-1251'),
                          'var' => $gal,
                          'err' => undef,
                         );
        
            return 1;

            }

        }

        $self->render(template => 'personal/gallery/preview',
                'message' => b('Галерея')->decode('cp-1251'),
                'var' => undef,
                'err' => undef,
            );

        return 1;
}

sub add {
    my $self = shift;

    my $mes = 'Новый альбом';
    decode 'cp-1251', $mes;

    $self->render(template => 'personal/gallery/edit',
                  var => undef,
                  message => $mes,
                  err => undef,
                  g_id => undef,
    );

}

sub insert {
    my $self = shift;

    my (%param, @err);

    push @err, b('Не указан заголовок статьи')->decode('cp-1251')
            unless $self->param('g_title');
    push @err, b('Не указано описание статьи')->decode('cp-1251')
            unless $self->param('g_description');

    if (@err) {
            my @cols = TestApp::Model::Gallery->select()->columns;

            foreach (@cols) {
                $param{$_} = $self->param($_);
                decode 'cp-1251', $param{$_};
            }

            $self->render(template => 'personal/gallery/edit',
                          'message' => b('Альбом')->decode('cp-1251'),
                          'var' => \%param,
                          'err' => \@err,
                          'g_id' => undef,
                         );
        return 1;
    }

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
    $image->move_to($ENV{TEMP_IMG} . $image_name . ".$ext");

    #$image->move_to($ENV{TEMP_IMG} . $image_name . ".$ext");

    TestApp::Model->init_image();
    
    TestApp::Model::Image->optimize($image_name, $ext);

    TestApp::Model::Image->scale(200, $image_name . '.jpg');

    $param{'g_id'}          = undef;
    $param{'g_create'}      = sprintf('%04d-%02d-%02d %02d:%02d:%02d', $year+1900, $mon+1, $mday, $hour, $min, $sec);
    $param{'g_cover'}       = $image_name . ".jpg";
    $param{'g_author_id'}   = $self->stash('USER')->{u_id};
    $param{'g_title'}       = $self->param('g_title');
    $param{'g_description'} = $self->param('g_description');
    $param{'g_comments'}    = 0;
    $param{'g_previews'}    = 0;
    
    my $row_id = TestApp::Model::Gallery->insert(\%param);

    $self->redirect_to('/personal/gallery');
}

sub update {
    my $self = shift;

    my (@err, $err, %param, $image, $old_data);
    my $g_id = $self->param('g_id');
    my $photos;

    push @err, b('Не указан заголовок статьи')->decode('cp-1251')
            unless $self->param('g_title');
    push @err, b('Не указано описание статьи')->decode('cp-1251')
            unless $self->param('g_description');


    $photos = TestApp::Model::Photos->select('', 'g_id=\''.$self->param('g_id').'\'', '')->hashes;
    $photos = undef unless $photos;
            
    if (@err) {
            my @cols = TestApp::Model::Gallery->select()->columns;

            $old_data = TestApp::Model::Gallery->select('', 'g_id=\''.$self->param('g_id').'\'', '')->hash;

            foreach (@cols) {
                $param{$_} = $self->param($_);
                decode 'cp-1251', $param{$_};
            }

            $param{'g_cover'} = $old_data->{'g_cover'};

            $self->render(template => 'personal/gallery/album',
                          'message' => b('Редактировать альбом: ')->decode('cp-1251') . $param{'g_title'},
                          'var' => \%param,
                          'err' => \@err,
                          'g_id' => $self->param('g_id'),
                          'photos' => $photos
                         );
        return 1;

    }

    $param{'g_title'} = $self->param('g_title');
    $param{'g_description'} = $self->param('g_description');

    my $update = TestApp::Model::Gallery->update(\%param, {'g_id' => $self->param('g_id')});

    my $new = TestApp::Model::Gallery->select('', 'g_id=\''.$self->param('g_id').'\'', '')->hash;

    decode 'cp-1251', $new->{'g_title'};
    decode 'cp-1251', $new->{'g_description'};

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

    $self->render(template => 'personal/gallery/album',
                          'message' => b('Редактировать альбом')->decode('cp-1251'),
                          'var' => $new,
                          'err' => $err,
                          'path' => $ENV{ORIG_IMG},
                          'photos' => $photos,
                          'g_id' => $self->param('g_id'),
                         );
    return 1;
}

sub gal_edit {
    my $self = shift;
    my $g_id = $self->stash('g_id');
    my ($edit, $photos, $mes);

    if ($g_id > 0) {
        $edit = TestApp::Model::Gallery->select('*', 'g_id=\'' . $g_id . '\'')->hash;
        decode 'cp-1251', $edit->{'g_title'};
        decode 'cp-1251', $edit->{'g_description'};

        $photos = TestApp::Model::Photos->select('', 'g_id=\'' . $g_id . '\'', '')->hashes;
        $photos = undef unless $photos;

        $mes = 'Редактировать альбом: ';
        decode 'cp-1251', $mes;

        $self->render(template => 'personal/gallery/album',
                      var => $edit,
                      photos => $photos,
                      message => $mes . $edit->{'g_title'},
                      err => undef,
                      g_id => $g_id,
        );
        return 1;
    }
    
    $self->redirect_to('/personal');
}

sub delete_gal {
    my $self = shift;

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
        my $del;
        $del = TestApp::Model::Gallery->delete(
                {'g_id' => $self->param('g_id')}
            );
        $del = TestApp::Model::Photos->delete(
                {'g_id' => $self->param('g_id')}
            );

        $self->redirect_to('/personal/gallery');
}

1;