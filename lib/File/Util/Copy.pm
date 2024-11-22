package File::Util::Copy;

use 5.010001;
use strict;
use warnings;
use Log::ger;

use Exporter 'import';
use File::Copy ();

# AUTHORITY
# DATE
# DIST
# VERSION

our @EXPORT_OK = qw(
                       copy_noclobber
                       copy_warnclobber
               );

sub copy_noclobber {
    my $opts = ref $_[0] eq 'HASH' ? shift : {};
    $opts->{pattern} //= " (%02d)";

    my ($from, $to) = @_;
    my $ext; $to =~ s/(\.\w+)\z// and $ext = $1;

    # XXX handle when to is a filehandle ref/blob, which File::Copy supports

    my $i = 0;
    my $to_final;
    while (1) {
        if ($i) {
            my $suffix = sprintf $opts->{pattern}, $i;
            $to_final = $ext ? "$to$suffix$ext" : "$to$suffix";
        } else {
            $to_final = $to;
        }
        lstat $to_final;
        last unless -e _;
        $i++;
    }
    File::Copy::copy($from, $to_final);
}

sub copy_warnclobber {
    my $opts = ref $_[0] eq 'HASH' ? shift : {};
    $opts->{log} //= 0;

    my ($from, $to) = @_;

    # XXX handle when to is a filehandle ref/blob, which File::Copy supports
    if (-e $to) {
        if ($opts->{log}) {
            log_warn "copy_warnclobber(`$from`, `$to`): Target already exists, renaming anyway ...";
        } else {
            warn "copy_warnclobber(`$from`, `$to`): Target already exists, renaming anyway ...\n";
        }
    }

    File::Copy::copy($from, $to);
}

1;
# ABSTRACT: Utilities related to copying files

=head1 SYNOPSIS

 use File::Util::Copy qw(
     copy_noclobber
     copy_warnclobber
 );

 copy_noclobber "foo.txt", "bar.txt"; # will copy to "bar (01).txt" if "bar.txt" exists (or "bar (02).txt" if "bar (01).txt" also exists, and so on)

 copy_warnclobber "foo.txt", "bar.txt"; # will emit a warning to stdrr if "bar.txt" exists, but copy/overwrite it anyway


=head1 DESCRIPTION

=head2 copy_noclobber

Usage:

 copy_noclobber( [ \%opts , ] $from, $to );

Known options:

=over

=item * pattern

Str. Defaults to " (%02d)".

=back

=head2 copy_warnclobber

Usage:

 copy_warnclobber( [ \%opts , ] $from, $to );

Known options:

=over

=item * log

Bool. If set to true, will log using L<Log::ger> instead of printing warning to
stderr.

=back


=head1 SEE ALSO

L<File::Copy::NoClobber> also has a non-clobber version of copy()

=cut
