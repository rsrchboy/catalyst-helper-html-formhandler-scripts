package Catalyst::Helper::HTML::FormHandler::Scripts;

# ABSTRACT: Create a script/myapp_hfh.pl to help with forms

use namespace::autoclean;
use common::sense;

use File::Spec;

sub mk_stuff {
    my ($self, $helper, $args) = @_;

    my $base = $helper->{base};
    my $app  = lc $helper->{app};

    $app =~ s/::/_/g;

    my $script = File::Spec->catfile($base, 'script', $app.'_hfh.pl');
    $helper->render_file('hfh', $script);
    chmod 0755, $script;
}


1;

=head1 SYNOPSIS

    ./script/myapp_create.pl HTML::FormHandler::Scripts

=head1 DESCRIPTION

This is a Catalyst helper module that builds a
L<HTML::FormHandler> form for you, from your L<DBIx::Class> schema,
using L<HTML::FormHandler::Model::DBIC>.

VERY EARLY CODE: things may yet change, but shouldn't impact older versions
(unless you regenerate the script).

=head1 DEPENDENCIES

The generated script depends on: L<HTML::FormHandler::Generator::DBIC>,
L<Config::JFDI>, L<opts>, L<aliased>.

=head1 SEE ALSO

L<DBIx::Class>, L<HTML::FormHandler>, L<HTML::FormHandler::Model::DBIC>.

=cut

__DATA__
__hfh__
#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../lib";

use aliased 'HTML::FormHandler::Generator::DBIC' => 'Generator';
use opts;
use Class::MOP;
use Config::JFDI;

opts
    my $schema => { isa => 'Str', default  => 'DB::Schema' },
    my $model  => { isa => 'Str', default  => 'Model::DB'  },
    my $rs     => { isa => 'Str', required => 1            },
    ;

$schema = "[% app %]::$schema";

# if we die, we die
Class::MOP::load_class($schema);

my $connect_info = Config::JFDI
    ->new(name => '[% app %]')
    ->get
    ->{$model}
    ->{'connect_info'}
    ;

my $gen = Generator->new(
    db_dsn      => $connect_info->{dsn},
    schema_name => $schema,
    rs_name     => $rs,
);

print $gen->generate_form;

1;
