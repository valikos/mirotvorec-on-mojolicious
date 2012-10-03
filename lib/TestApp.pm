package TestApp;

use Mojo::Base 'Mojolicious';
use Mojolicious::Sessions;

use Data::Dumper;

# This method will run once at server start
sub startup {
    my $self = shift;

    $self->plugin(captcha_renderer => { size => 20, color => 'green'});
    $self->plugin('TagHelpers');

=head
    open for server
    $self->hook( before_dispatch => sub {
        my $self = shift;
        # notice: url must be fully-qualified or absolute, ending in '/' matters.
        $self->req->url->base(Mojo::URL->new(q{http://www.mirotvorec.zp.ua/}));
    });
=cut

    # выставляем секретный код
    $self->secret('VaLiKoS');
    $self->sessions->default_expiration(360000);
    # $self->sessions->cookie_path('/');

    #$self->types->type(html => 'text/html; charset=UTF-8');
    # устанавливаем кодировку страницы
    $self->renderer->encoding('utf8');
    #$self->plugin(charset => {charset => 'utf-8'});

    # роутер
    my $r = $self->routes;
    $r->namespace('TestApp::Controller');
    $r->route('/mail')->to('index#my_mail');

    ##################
    # Основная часть #
    ################## =========================================================================
    my $auth = $r->bridge->to(controller => 'auth', action => 'authenfication');

    $auth->route('/sign_in') ->via('post')->to('auth#sign_in')->name('auth_sign_in');
    $auth->route('/sign_out')->via('get')->to('auth#sign_out')->name('auth_sign_out');

    $auth->route('/images/code.png')->to('guestbook#gen_cpt');

    # articles
    $auth->route('/:page/:num', 'page' => qr/page/, 'num' => qr/\d+/)->to('index#welcome', page => 'page', num => 1)->name('index_welcome');
    $auth->route('/article/:id', 'id' => qr/\d+/)->to('index#detail')->name('index_detail');
    # $auth->route('/article/:id/addcomment', 'id' => qr/\d+/)->via('post')->to('index#add_comment')->name('index_add_comment');

    # comments actions
    $auth->route('/get/comment/:id', 'id' => qr/\d+/)->via('get')->to('comment#get_comment');
    $auth->route('/add/comment/:article_id', 'article_id' => qr/\d+/)->via('post')->to('comment#add_comment');
    $auth->route('/add/gallery/comment/:gallery_id', 'gallery_id' => qr/\d+/)->via('post')->to('comment#add_comment_gal');
    $auth->route('/update/comment/:c_id', 'c_id' => qr/\d+/)->via('post')->to('comment#update_comment');
    $auth->route('/delete/comment/:c_id', 'c_id' => qr/\d+/)->via('delete')->to('comment#delete_comment', 'c_id' => '0');
    # $auth->route('/delete/comment/:c_id', 'c_id' => qr/\d+/)->via('delete')->to('delete#comment', 'c_id' => '0');

    # personal
    $auth->route('/personal/edit')->via('get')->to('personal#get_edit_info');
    $auth->route('/user/:user')->via('get')->to('personal#get_info', 'user'=>'');
    $auth->route('/personal/change')->via('post')->to('personal#update_info');

    # personal gallery for front side
    $auth->route('/personal/gallery')->via('get')->to('personal#gallery');
    $auth->route('/personal/gallery/add')->via('get')->to('personal#add');
    $auth->route('/personal/gallery/insert')->via('post')->to('personal#insert');
    $auth->route('/personal/gallery/update')->via('post')->to('personal#update');
    $auth->route('/personal/gallery/edit/:g_id', 'g_id' => qr/\d+/)->via('get')->to('personal#gal_edit', num => 0);
    $auth->route('/personal/gallery/delete_gal')->via('post')->to('personal#delete_gal');
    # gallery show and preview
    $auth->route('/gallery')->via('get')->to('gallery#show');
    $auth->route('/gallery/preview/:id', 'id' => qr/\d+/)->to('gallery#preview');
    $auth->route('/gallery/:id/addcomment', 'id' => qr/\d+/)->via('post')->to('gallery#add_comment');

    # register
    $auth->route('/register')->via('get') ->to('auth#show_form')->name('auth_show_form');
    $auth->route('/register')->via('post')->to('auth#regist')->name('new_user_reg');

    # static pages
    $auth->route('/contacts')->to('contact#info')->name('contact_info');
    $auth->route('/event')->to('event#show')->name('event_show');
    $auth->route('/rules')->to('index#rules');
    # $r->route('/')->to('event#show')->name('event_show');

    # guestbook
    $auth->route('/guestbook/:page/:num', 'num' => qr/\d+/, 'page' => qr/page/)->
        via('get')->to('guestbook#show', page => 'page', num => 1)->name('guestbook_show');
    $auth->route('/guestbook/:page/:num/:add', add => qr/add/)->via('post')->to('guestbook#show')->name('guestbook_add_comment');

    # save upload photos
    $r->route('/uploadify/commit')->via('post')->to('controller' => 'uploadify', 'action' => 'commit');

    ###################
    # Админская часть #
    ################### ========================================================================
    my $admin = $r->bridge->to(controller => 'admin', action => 'admin_check');

    $admin->route('/admin/rules')->to('admin#rules');

    $admin->route('/admin')->via('get')       ->to('admin#index_page')->name('admin_index_page');
    $r    ->route('/admin')->via('post')      ->to('admin#login')     ->name('admin_login');
    $admin->route('/admin/sign_out')->via('get')->to('admin#sign_out')->name('admin_sign_out');
    $admin->route('/admin/bbcode/preview')    ->to('admin#bbcode_preview')->name('bbcode_preview');

    $admin->route('/admin/users')->to(namespace => 'TestApp::Controller::Admin', controller=>'users', action=>'users')->name('admin_users');

    # статьи
    $admin->route('/admin/articles')->to(namespace => 'TestApp::Controller::Admin', controller=>'articles', action=>'articles')->name('admin_articles');
    $admin->route('/admin/album_uploader')->to(namespace => 'TestApp::Controller::Admin', controller=>'gallery', action=>'album_uploader');
    
    $admin->route('/admin/guestbook/:p/:num', p => qr/p/, num => qr/\d+/, )->to(num => '', p => '', namespace => 'TestApp::Controller::Admin', controller=>'guestbook', action=>'guestbook');
    #$admin->route('/admin/gallery')  ->to(namespace => 'TestApp::Controller::Admin', controller=>'gallery', action=>'gallery')->name('admin_gallery');

    # gallery
    # $admin->route('/admin/gallery')->to(namespace => 'TestApp::Controller::Admin', controller=>'gallery', action=>'gallery')->name('admin_gallery');
    $admin->route('/admin/gallery/:num', 'page' => 'page', 'num' => qr/\d+/)->via('get')->to('num' => 1, namespace => 'TestApp::Controller::Admin', controller=>'gal', action=>'get_albums');
    $admin->route('/admin/gallery/:num/create', 'num' => qr/\d+/)->via('get')->to(num => '1', namespace => 'TestApp::Controller::Admin', controller => 'gal', action => 'new_album');
    $admin->route('/admin/gallery/edit/:g_id/:page', 'g_id' => qr/\d+/, 'page' => qr/\d+/)->via('get')->to(page => '1', g_id => '0', namespace => 'TestApp::Controller::Admin', controller => 'gal', action => 'edit_album');
    $admin->route('/admin/gallery/edit/:g_id/:page', g_id => qr/\d+/, page => qr /\d+/)->via('post')->to(page => 0, g_id => 0, namespace => 'TestApp::Controller::Admin', controller => 'gal', action => 'update_album');
    $admin->route('/admin/gallery')->via('post')->to(namespace => 'TestApp::Controller::Admin', controller => 'gal', action => 'create_album');
    $admin->route('/admin/gallery/delete/:g_id', 'g_id' => qr/\d+/)->via('post')->to(namespace => 'TestApp::Controller::Admin', controller => 'gal', action => 'delete_album', 'g_id' => '0');
    $admin->route('/admin/gallery/photo/delete/:g_id/:p_id', 'g_id' => qr/\d+/, 'p_id' => qr/\d+/)->via('delete')->to(namespace => 'TestApp::Controller::Admin', controller => 'gal', action => 'delete_photo', 'g_id' => '0', 'p_id' => '0');

    # demo_editor
    $r->route('/demo_editor')->to('index#demo');
    #################
    #   uploadify   #
    #################
    $r->route('/uploadify/check')->via('post')->to('uploadify#check');

    ##################
    #     Модель     #
    ################## =========================================================================
     Mojo::Loader->load('TestApp::Model');

    TestApp::Model->init_db({
        dsn      => 'dbi:SQLite:dbname=' . $self->home->rel_dir('db') . '/mir.db',
        user     => '',
        password => '',
    });

} # end of statrup

1;
