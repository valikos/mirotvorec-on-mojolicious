package TestApp::Model;

use strict;
use warnings;

use DBIx::Simple;
use SQL::Abstract;
use Parse::BBCode;
use Image::Magick;

use Carp qw/croak/;

use Mojo::Loader;
use Mojo::ByteStream;

my $modules = Mojo::Loader->search('TestApp::Model');
for my $module (@$modules) {
        Mojo::Loader->load($module);
}

my $DB;
my $BBC;
my $IMG;

# иницифлизация указателя БД
sub init_db {
    my ($class, $config) = @_;
    croak "No dsn was passed!" unless $config && $config->{'dsn'};

    unless ( $DB ) {
        $DB = DBIx::Simple->connect(@$config{qw/dsn user password/},
            {
                RaiseError     => 1,
                sqlite_unicode => 1,
            }
        )  or die DBIx::Simple->error;

        $DB->abstract = SQL::Abstract->new(
               case          => 'lower',
               logic         => 'and',
               convert       => 'upper'
        );
    }

    return $DB;

}

# возврат указателя БД
sub db {
    return $DB if $DB;
    croak 'You should init model first';
}

# init BBcode
sub init_bbcode {
    my ($class) = shift;

    unless ($BBC) {
        $BBC = Parse::BBCode->new(
        {
            tags => {
                # Parse::BBCode::HTML->defaults,
                # add your own tags here if needed
                'b'     => '<strong>%s</strong>',
                'i'     => '<em>%s</em>',
                'u'     => '<div style="text-decoration:underline">%s</div>',
                's'     => '<del>%s</del>',
                
                'left'  => '<div style="text-align:left">%s</div>',
                'center'=> '<div style="text-align:center">%s</div>',
                'right' => '<div style="text-align:right">%s</div>',
                
                'img'   => '<img src="%{link}A" alt="[%{html}s]" title="%{html}s">',
                'url'   => 'url:<a href="%{link}A" rel="nofollow">%s</a>',
                'email' => 'url:<a href="mailto:%{email}A">%s</a>',
                'size'  => '<span style="font-size: %{num}a">%s</span>',
                'color' => '<span style="color: %{htmlcolor}a">%s</span>',
                'quote' => 'block:<blockquote class="quote">%s</blockquote>',
                # 'quote' => 'block:<div class="bbcode_quote_header"><span class="title">%{html}a:</span>
                # <div class="bbcode_quote_body">%s</div></div>',
                'noparse' => '%{html}s',
            },
            escapes => {
               Parse::BBCode::HTML->default_escapes,
            },
        }
        );
    }
    return $BBC;
}

sub bbcode {
    return $BBC if $BBC;
    croak 'You should init BBCodes model first';
}

sub init_image {
    my ($class) = shift;

    unless ($IMG) {
        $IMG = Image::Magick->new();
    }

    return $IMG;
}

sub image {
    return $IMG if $IMG;
    croak 'You should init Image::Magick model first';
}

1;