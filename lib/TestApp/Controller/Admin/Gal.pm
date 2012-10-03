package TestApp::Controller::Admin::Gal;

use strict;
use warnings;

use base 'Mojolicious::Controller';

use Mojo::ByteStream 'b';
use Mojo::Util qw'trim';
use Data::Dumper;

__PACKAGE__->attr(conf => sub { do 'conf/text_massages.conf' });

# get list of albums
sub get_albums {
    my $self = shift;

#    my $page = $self->param('page') || '1';
    my $ac = $self->param('ac') || 'view';
    my $g_id = $self->param('g_id') || '0';

    my $page = $self->stash('num');

    $self->stash('ac'   => $ac);
    $self->stash('g_id' => $g_id);
    $self->stash('page' => $page);
    $self->stash('page_id' => 'gallery');
    
    my $cc = TestApp::Model::Gallery->select('count(g_id)')->list;

    my ($gallery, $err);
    $err = undef;
    $gallery = undef;

    if ($cc > 0) {

        if ( ($cc / $ENV{ITEMS_ON_PAGE}) <= 1) {
            $self->stash('pages' => 0);
        } else {
            $self->stash('pages' => int($cc / $ENV{ITEMS_ON_PAGE}) + 1);
        }

        # $gallery = TestApp::Model::Gallery->select()->hashes;
        $gallery = TestApp::Model::Base->select_join(
            'gallery as g, users as u',
            'g.*, u.u_login', 
            'g.g_author_id=u.u_id', 
            'g.g_id'
        )->hashes;
        
        foreach (@$gallery) {
            my ($second, $minute, $hour, $mday, $month, $year, $wday) = localtime($_->{'g_create'});
            $_->{'g_create'} = sprintf(
                    '%02d.%02d.%04d %02d:%02d',
                    $mday, $month+1, $year+1900, $hour, $minute
            );
        } 
    }

    $self->render(template => 'admin/gallery/preview',
                'var' => $gallery,
                'err' => undef,
    );
    
    return 1;
}

# new album
sub new_album {
    my $self = shift;
    
    $self->stash('page_id' => 'gallery');
    
    $self->render(
        'template' => 'admin/gallery/new',
        'params',  => undef,
        'errors'   => undef,
        'var' => undef,
        'CFG' => '',
    )
}

# create new album, save album data
sub create_album {
    # TODO author name???
    my $self = shift;
    # load config
    my $cfg = $self->conf;
    # decode config
    foreach (keys %$cfg){
        $cfg->{$_} = b($cfg->{$_})->decode('utf-8');
    }
    $self->stash('CFG' => $cfg);
    $self->stash('page_id' => 'gallery');

    my (@err, %param, $image_type, %valid_types, $file_name, $image, $upload, $size);

    %valid_types = map {$_ => 1} qw(image/jpeg image/png);

    # init image & content_type
    $upload = $self->req->upload('preview');
    $file_name = $upload->filename;
    $image = $upload->filename;
    $image_type = $upload->headers->content_type;
    $size = $upload->size;

    # check errors
    # 1 - empty data
    push @err, 'author'      unless $self->param('g_author');
    push @err, 'title'       unless $self->param('g_title');
    push @err, 'description' unless $self->param('g_description');
    push @err, 'empty_file'  unless $image;

    # 2 - valid image extension
    if ($image && $size > 0){
        push @err, 'image_ext'  unless $valid_types{$image_type};
    }

    if (@err) {

        $param{'g_author_id'}   = $self->param('g_author_id') || $self->stash('ADMIN')->{u_id};
        $param{'g_title'}       = $self->param('g_title') || '';
        $param{'g_description'} = $self->param('g_description') || '';
        $param{'g_publish'}     = 1;

        $self->render(
            'template' => 'admin/gallery/new',
            'var',     => \%param,
            'errors'   => \@err,
            'num'      => '1',
        );

        return 1;
    }

    # get date
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime(time);
    $mon += 1;
    $year += 1900;

    # get gallery table columns
    my @cols = TestApp::Model::Gallery->select()->columns;

    foreach (@cols) {
        $param{$_} = $self->param($_);
    }

    # unique image name
    my $image_name = sprintf('image-%04s%02s%02s%02s%02s%02s-%05d', $year, $mon, $mday, $hour, $min, $sec, int rand(10000));
    
    # Extention
    my $exts = {
        'image/jpeg' => 'jpg',
        'image/png' => 'png'
    };
    my $ext = $exts->{$image_type};

    # save original image
    $upload->move_to($ENV{MOJO_TMPDIR} . $image_name . ".$ext");

    TestApp::Model->init_image();
    TestApp::Model::Image->optimize($image_name, $ext);
    TestApp::Model::Image->scale(150, $image_name . '.png');
    # delete tmp image
    unlink $ENV{MOJO_TMPDIR} . $image_name . ".$ext" if -f $ENV{MOJO_TMPDIR} . $image_name . ".$ext";

    $param{'g_id'}          = undef;
    $param{'g_create'}      = time; # sprintf('%04d-%02d-%02d %02d:%02d:%02d', $year+1900, $mon+1, $mday, $hour, $min, $sec);
    $param{'g_cover'}       = $image_name . ".png"; # save image at PNG format
    $param{'g_author_id'}   = $self->param('g_author_id') || $self->stash('ADMIN')->{u_id};
    $param{'g_title'}       = $self->param('g_title');
    $param{'g_description'} = trim $self->param('g_description');
    $param{'g_comments'}    = 0;
    $param{'g_previews'}    = 0;
    $param{'g_publish'}     = 1;

    my $row_id = TestApp::Model::Gallery->insert(\%param);

    $self->redirect_to('/admin/gallery');
}

# update album data
sub update_album {
    my $self = shift;

    # load config
    my $cfg = $self->conf;
    # decode config
    foreach (keys %$cfg){
        $cfg->{$_} = b($cfg->{$_})->decode('utf-8');
    }

    $self->stash('CFG' => $cfg);
    
    $self->stash('page_id' => 'gallery');
    $self->stash('page' => $self->param('page') || 1);
    
    # get album and photos data
    my $g_id = $self->param('g_id');
    my $edit = TestApp::Model::Base->select_join(
                    'gallery as g join users as u on (g.g_author_id=u.u_id)',
                    'g.*, u.u_login',
                    'g_id=\'' . $g_id . '\''
    )->hash;
    
    my $photos = TestApp::Model::Photos->select('', 'g_id=\'' . $g_id . '\'', '')->hashes;
    $photos = '' unless $photos;

    my (@err, %param, $image_type, %valid_types, $file_name, $image, $upload, $size);
    
    %valid_types = map {$_ => 1} qw(image/jpeg image/png);

    $upload = $self->req->upload('preview');
    $file_name = $upload->filename;
    $image = $upload->filename;
    $image_type = $upload->headers->content_type;
    $size = $upload->size;

    # check errors
    # 1 - empty data
    push @err, 'title'       unless $self->param('g_title');
    push @err, 'description' unless $self->param('g_description');

    # 2 - valid image extension
    if ($image && $size > 0) {
        push @err, 'image_ext' unless $valid_types{$image_type};
    }

    if (@err) {

        $param{'g_title'}       = $self->param('g_title') || '';
        $param{'g_description'} = $self->param('g_description') || '';
        $param{'g_publish'}     = $self->param('g_publish') || '';

        $self->render(
            'template' => 'admin/gallery/album',
            'var',  => \%param,
            'err'   => \@err,
            'album' => $edit,
            'photos' => $photos,
        );

        return 1;
    }

    # get date
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime(time);
    $mon += 1;
    $year += 1900;

    # unique image name
    if ($image && $size > 0) {
        my $image_name = sprintf('image-%04s%02s%02s%02s%02s%02s-%05d', $year, $mon, $mday, $hour, $min, $sec, int rand(10000));

        # Extention
        my $exts = {
        'image/jpeg' => 'jpg',
            'image/png' => 'png'
        };
        my $ext = $exts->{$image_type};

        # save original image
        $upload->move_to($ENV{MOJO_TMPDIR} . $image_name . ".$ext");

        TestApp::Model->init_image();
        TestApp::Model::Image->optimize($image_name, $ext);
        TestApp::Model::Image->scale(150, $image_name . '.png');
        # delete tmp image
        unlink $ENV{MOJO_TMPDIR} . $image_name . ".$ext" if -f $ENV{MOJO_TMPDIR} . $image_name . ".$ext";
        # unlink old image 
        unlink $ENV{ORIG_IMG} . $edit->{'g_cover'} if -f $ENV{ORIG_IMG} . $edit->{'g_cover'};
        unlink $ENV{SCALE_IMG} . $edit->{'g_cover'} if -f $ENV{SCALE_IMG} . $edit->{'g_cover'};
        
        $param{'g_cover'}       = $image_name . ".png"; # save image at PNG format
    }

    # set publish option
    my $p;
    if ($self->stash('ADMIN')->{u_id} eq $edit->{g_author_id} || $self->stash('ADMIN')->{u_mode} eq  2) {
        $p = $self->param('g_publish') eq 1 ? 1 : 0;
    }
    
    # set update data
    $param{'g_publish'}     = $p if ($p =~ /1|0/);
    $param{'g_title'}       = $self->param('g_title');
    $param{'g_description'} = trim $self->param('g_description');

    my $row_id = TestApp::Model::Gallery->update(\%param, {'g_id' => $self->param('g_id')});

    $self->redirect_to('/admin/gallery/edit/'.$self->stash('g_id').'/'.$self->param('page'));
}

# preview album
sub edit_album {
    my $self = shift;

    my $cfg = $self->conf;
    # decode config
    foreach (keys %$cfg){
        $cfg->{$_} = b($cfg->{$_})->decode('utf-8');
    }
    $self->stash('CFG' => $cfg);

    my $g_id = $self->stash('g_id');
    my $page = $self->stash('page');

    $self->stash('page_id' => 'gallery');

    my ($edit, $photos, $cc);
    my (@err, %param, $param);

    if ($g_id > 0) {

        $edit = TestApp::Model::Base->select_join(
                    'gallery as g join users as u on (g.g_author_id=u.u_id)',
                    'g.*, u.u_login',
                    'g_id=\'' . $g_id . '\''
        )->hash;

        $cc = TestApp::Model::Photos->select('count()', 'g_id=\'' . $g_id . '\'', '')->list;
        if ($cc > 0) {
            $photos = TestApp::Model::Photos->select('', 'g_id=\''.$g_id.'\'', '')->hashes;
        } else {
            $photos = 0;
        }

        $self->render(template => 'admin/gallery/album',
                      album => $edit,
                      photos => $photos,
                      #err => undef,
                      g_id => $g_id,
        );
        return 1;
    }

    $self->redirect_to('/admin/gallery/' . $page);
}

# delete gallery
sub delete_album {
    my $self = shift;
    my $g_id = $self->stash('g_id');
    
    my ($gallery, $photos, $cc);
    
    $cc = TestApp::Model::Gallery->select('count()', "g_id='$g_id'" , '')->list;
    
    if ($cc > 0) {
        $gallery = TestApp::Model::Gallery->select('*', "g_id='$g_id'" , '')->hash;
        # delete gallery cover
        unlink $ENV{ORIG_IMG} . $gallery->{g_cover} if -f $ENV{ORIG_IMG} . $gallery->{g_cover};
        unlink $ENV{SCALE_IMG} . $gallery->{g_cover} if -f $ENV{SCALE_IMG} . $gallery->{g_cover};
        # select gallery photos
        $photos = TestApp::Model::Photos->select('*', "g_id='$g_id'" , '')->hashes;
        foreach (@$photos) {
            unlink $ENV{ORIG_IMG} . $_->{p_name} if -f $ENV{ORIG_IMG} . $_->{p_name};
            unlink $ENV{SCALE_IMG} . $_->{p_name} if -f $ENV{SCALE_IMG} . $_->{p_name};
        }
        # delete all data from DB
        TestApp::Model::Gallery->delete({'g_id' => $g_id});
        TestApp::Model::Photos->delete({'g_id' => $g_id});
    }

    $self->redirect_to('/admin/gallery');
}

# delete photo from album
sub delete_photo {
    my $self = shift;
    my ($g_id, $p_id) = ($self->stash('g_id'), $self->stash('p_id'));
    
    my ($count, $photo, $status);

    $photo = TestApp::Model::Photos->select('*', "g_id='$g_id' AND p_id='$p_id'" , '')->hash;

    TestApp::Model::Photos->delete({'g_id' => $g_id, 'p_id' => $p_id});

    # check delete
    $count = TestApp::Model::Photos->select('count()', "g_id='$g_id' AND p_id='$p_id'" , '')->list;
    warn Dumper $count;
    if ($count eq 0) {
        $status = 1;
        unlink $ENV{ORIG_IMG} . $photo->{p_name} if -f $ENV{ORIG_IMG} . $photo->{p_name};
        unlink $ENV{SCALE_IMG} . $photo->{p_name} if -f $ENV{SCALE_IMG} . $photo->{p_name};
    } else {
        $status = -1;
    }
    $self->render(json => $status);
}

1;
__END__