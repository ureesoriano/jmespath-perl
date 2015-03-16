#!/usr/bin/env perl
use strict; use warnings;
use File::Slurp;
use Parse::ABNF ;
Main( @ARGV );
exit( 0 );

sub Main {
    my $rules = Parse::ABNF->new->parse(  scalar read_file( shift ) );
    print "\n\n", Value( $rules ), "\n\n";
}

BEGIN {
    my %class = (
        Choice => \&Choice,
        Group => \&Group,
        Range => \&Range,
        Reference => \&Reference,
        Repetition => \&Repetition,
        Rule => \&Rule,
        String => \&String,
        Literal => \&Literal,
        ProseValue => \&ProseValue,
    );

    sub Value {
        my $ret = "";
        my( $v , $dent ) = @_;
        $dent ||= 0;
        if( UNIVERSAL::isa($v, 'ARRAY') ){
            $ret .= join '', map { Value($_ , $dent ) } @$v;
        } elsif( UNIVERSAL::isa($v, 'HASH') ){
            $ret .= $class{ $$v{class}  }->( $v , $dent  );
        } else {
            warn $v;
        }
        $ret;
    }
}

sub Choice {
    my $ret = "";
    my( $v, $dent ) = @_;
    $ret .= join ' | ', map { Value($_ , $dent+1) } @{$$v{value}};
    $ret ;
}

sub Group {
    my $ret = "";
    my( $v, $dent ) = @_;
    $ret .= "(?: ". Value( $$v{value}  , $dent+1) .' )';
    $ret ;
}

sub Reference {
    my $ret = "";
    my( $v, $dent ) = @_;
    $ret .= "<@{[fixRulename($$v{name})]}>";
    $ret ;
}

sub Repetition {
    my $ret = "";
    my( $v, $dent ) = @_;
    no warnings 'uninitialized';
    my %mm = (
        # max min
        "1 0" => '?',
        " 0" => '*',
        " 1" => '+',
    );
    if( my $mm = $mm{"$$v{max} $$v{min}"} ){
        $ret .= " (?: ". Value($$v{value}  , $dent+1)." )$mm ";
    } elsif( $$v{min} == $$v{max} ){
        $ret .= " (?: ". Value($$v{value}  , $dent+1)." ){$$v{max}} ";
    } else {
        $ret .= " (?: ". Value($$v{value}  , $dent+1)." ){$$v{min}, $$v{max}} ";
    }
    $ret ;
}

sub Rule {
    my $ret = "";
    my( $v, $dent ) = @_;
    my $name = $$v{name};
    if( 'ws' eq lc $name  ){
        warn "Changing rule ws to token to avoid 'infinitely recursive unpleasantness.'\n";
        $ret .= "<token: ws>\n  ";
    } else {
        $ret .= "<rule: @{[fixRulename($$v{name})]}>\n  ";
    }
    $ret .= Value( $$v{value}  , $dent+1);
    $ret . "\n\n";
}

#~ @{[fixRulename($$v{name})]}
sub fixRulename {
    my( $name ) = @_;
    $name =~ s/\W/_/g;
    $name;
}
sub Range {
    my $ret = "";
    my( $v, $dent ) = @_;
    $ret .= '[';
    if( $$v{type} eq 'hex' ){
        $ret .= join '-', map { '\x{'.$_.'}' } $$v{min}, $$v{max};
    } elsif( $$v{type} eq 'binary' ){
        $ret .= join '-', map { sprintf '\\%o', oct "0b$_" } $$v{min}, $$v{max};
    } elsif( $$v{type} eq 'decimal' ){
        $ret .= join '-', map { sprintf '\\%o', $_ } $$v{min}, $$v{max};
    } else {
        warn "## Range type $$v{type}  $$v{value} \n";
    }
    $ret .= "]";
    $ret ;
}

sub String {
    my $ret = "";
    my( $v, $dent ) = @_;
    if( $$v{type} eq 'hex' ){
        $ret = join '', map { '\x'.$_ } @{$$v{value}};
    } elsif( $$v{type} eq 'binary' ){
        $ret .= join '', map { sprintf '\\%o', oct "0b$_" } @{$$v{value}};
    } elsif( $$v{type} eq 'decimal' ){
        $ret .= join '', map { sprintf '\\%o', $_ } @{$$v{value}};
    } else {
        warn "## String type $$v{type}  $$v{value} \n";
#~         warn "##",  map({ "$_ ( $$v{$_} ) " } sort keys %$v ), "\n";
    }
#~     " $ret ";
    $ret;
}

sub Literal {
    my $ret = "";
    my( $v, $dent ) = @_;
    $ret .=  quotemeta $$v{value} ;
    $ret ;
}

sub ProseValue {
    my $ret = "";
    my( $v, $dent ) = @_;
#~     warn "##",  map({ "$_ ( $$v{$_} ) " } sort keys %$v ), "\n";
#~     $ret .= "<$$v{value}>";
    $ret .= "<@{[fixRulename($$v{value})]}>";
    $ret ;
}
__END__
