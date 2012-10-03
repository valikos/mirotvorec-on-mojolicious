package TestApp::Model::Base;

use strict;
use warnings;
use base qw/Mojo::Base/;

use Data::Dumper;

#### Class Methods ####

sub select {
    my $class = shift;
    my ($fields, $where, $order) = @_;
    my $db = TestApp::Model->db;
    $db->select($class->table_name, $fields || '*', $where || q'', $order || q'');
}

sub insert {
    my $class = shift;
    my $db = TestApp::Model->db;
    $db->insert($class->table_name, @_) or die $db->error();
    $db->last_insert_id('','','','') or die $db->error();
}

sub update {
    my $class = shift;
    my $db = TestApp::Model->db;
    $db->update($class->table_name, @_) or die $db->error();
}

sub delete {
    my $class = shift;
    my $db = TestApp::Model->db;
    $db->delete($class->table_name, @_) or die $db->error();
}

sub select_join {
    my $class = shift;
    my ($from, $fields, $where, $order) = @_;
    my $db = TestApp::Model->db;
    $db->select($from, $fields, $where || q'', $order || q'');
}

1;
__END__
