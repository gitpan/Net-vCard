use ExtUtils::MakeMaker;

our $VERSION="0.3";

open ABSTRACT, "<", "ABSTRACT";
our $ABSTRACT=<ABSTRACT>;
chomp $ABSTRACT;
close ABSTRACT;

WriteMakefile(
    NAME         => 'Net::vCard',
    VERSION      => $VERSION,
    AUTHOR       => 'Jay J. Lawrence',
    ABSTRACT     => $ABSTRACT,
    PREREQ_PM    => {
    },

);

open VERSION, ">", "VERSION";
print VERSION "$VERSION";
close VERSION;

