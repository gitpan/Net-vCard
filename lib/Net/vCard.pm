package Net::vCard;

use strict;
use warnings;

our $VERSION=0.1;

=head1 NAME

Net::vCard - Read and write vCard files (RFC 2426). vCard files hold personal information that you would typically find on a business card. Name, numbers, addresses, and even logos. This module can also serve as a base class for other vFile readers.

=head1 SYNOPSIS

  use Net::vCard;

  my $cards=Net::vCard->loadFile( "addresses.vcf" );

  foreach my $card ( @$cards ) {
    print $card->{'N'}{'firstName'}, " ", $card->{'N'}{'lastName'}, "\n";
  }

=head1 MODULE STATUS

The current state of this module is a pretty solid parser and internal data structure.

Now I will be adding get/set handlers for the various properties. As well, I'd really like
to get some pathelogical data from different vCard producers. Right now I have a pretty good
handle on Apple's Addressbook - which is the whole reason why I wrote this stuff.

For those who really want to use this module right away

  - go ahead and access the hash values directly for the time being
  - keep in mind that I will be making a get/set method interface
  - once that is established you will need to use that interface instead

=cut


use base qw(Net::vFile);
$Net::vFile::classMap{'VCARD'}=__PACKAGE__;

sub FN   { $_[0]->_singleText( "FN", $_[1] ); }
sub BDAY { $_[0]->_singleText( "BDAY", $_[1] ); }

sub varHandler {

    return {
        'FN'          => 'singleText',
        'N'           => 'N',
        'NICKNAME'    => 'multipleText',
        'PHOTO'       => 'singleBinary',
        'BDAY'        => 'singleText',
        'ADR'         => 'ADR',
        'LABEL'       => 'singleTextTyped',
        'TEL'         => 'singleTextTyped',
        'EMAIL'       => 'singleTextTyped',
        'MAILER'      => 'singleText',
        'TZ'          => 'singleText',
        'GEO'         => 'GEO',
        'TITLE'       => 'singleText',
        'ROLE'        => 'singleText',
        'LOGO'        => 'singleBinary',
        'AGENT'       => 'singleText',
        'ORG'         => 'multipleText',
        'CATEGORIES'  => 'multipleText',
        'NOTE'        => 'singleText',
        'PRODID'      => 'singleText',
        'REV'         => 'singleText',
        'SORT-STRING' => 'singleText',
        'SOUND'       => 'singleBinary',
        'UID'         => 'singleText',
        'URL'         => 'singleText',
        'VERSION'     => 'singleText',
        'CLASS'       => 'singleText',
        'KEY'         => 'singleBinary',
    };

}

sub typeDefault {

    return {
        'ADR'     => [ qw(intl postal parcel work) ],
        'LABEL'   => [ qw(intl postal parcel work) ],
        'TEL'     => [ qw(voice) ],
        'EMAIL'   => [ qw(internet) ],
    };

}

sub load_N {

	die "load_N: @_ cannot have attributes\n" if $_[2];
	
    no warnings;
	my @parts = split /(?<!\\);/, $_[3];
	map { s/\\;/;/g; } @parts;

	my @additional = split /(?<!\\),/, $parts[2];
	map { s/\\,/,/g; } @additional;

	my @prefixes = split /(?<!\\),/, $parts[3];
	map { s/\\,/,/g; } @prefixes;

	my @suffixes = split /(?<!\\),/, $parts[4];
	map { s/\\,/,/g; } @suffixes;

	$_[0]->{$_[1]} = {
		familyName      => $parts[0],
		givenName       => $parts[1],
		additionalNames => \@additional,
		suffixes        => \@suffixes,
		prefixes        => \@prefixes,
	};

}

sub load_ADR {

    my $attr=$_[2];

    my %type=();
    map { map { $type{lc $_}=1 } split /,/, $_ } @{$attr->{TYPE}};
    my $typeDefault=$_[0]->typeDefault;
    map { $type{ lc $_ }=1 } @{$typeDefault->{$_[1]}} unless scalar(keys %type);

	my @parts = split /(?<!\\);/, $_[3];
	map { s/\\;/;/g; s/\\n/\n/gs; } @parts;

    my $pref=0;
    if ($type{pref}) {
        delete $type{pref};
        $pref=1;
    }
    my @types=sort keys %type;

	# What to do about comma separated things?

    my $actual=shift @types;
	$_[0]->{$_[1]}{$actual} = {
		poBox      => $parts[0],
		extended_address => $parts[1],
		address    => $parts[2],
		city       => $parts[3],
		region     => $parts[4],
		postalCode => $parts[5],
		country    => $parts[6],
	};

    $_[0]->{$_[1]}{_pref}=$actual if $pref;
    delete $_[0]->{$_[1]}{_alias}{$actual};
    map { $_[0]->{$_[1]}{_alias}{$_}=$actual unless exists $_[0]->{$_[1]}{$_} } @types;

}

=head1 SUPPORT

For technical support please email to jlawrenc@cpan.org ... 
for faster service please include "Net::vCard" and "help" in your subject line.

=head1 AUTHOR

 Jay J. Lawrence - jlawrenc@cpan.org
 Infonium Inc., Canada
 http://www.infonium.ca/

=head1 COPYRIGHT

Copyright (c) 2003 Jay J. Lawrence, Infonium Inc. All rights reserved.
This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.

=head1 ACKNOWLEDGEMENTS

 Net::iCal - who's loading code inspired me for mine

=head1 SEE ALSO

RFC 2426, Net::iCal

=cut

1;

