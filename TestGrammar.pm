package TestGrammar;

use File::Slurp;
use strict;
use warnings;

sub parse {
  my ($self, $input) = @_;

  use Regexp::Grammars;
  #my $grammar = read_file('jmespath.regexp');
  my $matcher = qr{
<logfile: - >
<expression>

<rule: expression>
  <sub_expression> | <index_expression> | <or_expression> | <identifier>
| \* | <multi_select_list> | <multi_select_hash> | <literal>
| <function_expression> | <pipe_expression>

<rule: sub_expression>
  (?: <expression>\.<identifier> | <multi_select_list> | <multi_select_hash> | <function_expression> | \* )

<rule: or_expression>
  (?: <expression>\|\|<expression> )

<rule: pipe_expression>
  (?: <expression>\|<expression> )

<rule: index_expression>
  (?: <expression><bracket_specifier> ) | <bracket_specifier>

<rule: multi_select_list>
  (?: \[(?: <expression> (?: (?: \,<expression> ) )*  )\] )

<rule: multi_select_hash>
  (?: \{(?: <keyval_expr> (?: (?: \,<keyval_expr> ) )*  )\} )

<rule: keyval_expr>
  (?: <identifier>\:<expression> )

<rule: bracket_specifier>
  (?: \[<number> | \* | <slice_expression>\] ) | \[\]
| (?: \[\?<list_filter_expr>\] )

<rule: list_filter_expr>
  (?: <expression><comparator><expression> )

<rule: slice_expression>
  (?:  (?: <number> )? \: (?: <number> )?  (?: (?: \: (?: <number> )?  ) )?  )

<rule: comparator>
  \< | \<\= | \=\= | \>\= | \> | \!\=

<rule: function_expression>
  (?: <unquoted_string><no_args> | <one_or_more_args> )

<rule: no_args>
  (?: \(\) )

<rule: one_or_more_args>
  (?: \((?: <function_arg> (?: (?: \,<function_arg> ) )*  )\) )

<rule: function_arg>
  <expression> | <current_node> | <expression_type>

<rule: current_node>
  \@

<rule: expression_type>
  (?: \&<expression> )

<rule: literal>
  (?: \`<json_value>\` )

<rule: literal>
  (?: \` (?: <unescaped_literal> | <escaped_literal> )+ \` )

<rule: unescaped_literal>
  [\x{20}-\x{21}] | [\x{23}-\x{5A}] | [\x{5D}-\x{5F}] | (?: [\x{61}-\x{7A}][\x{7C}-\x{10FFFF}] )

<rule: escaped_literal>
  <escaped_char> | (?: <escape>\x60 )

<rule: number>
  (?:  (?: \- )?  (?: <digit> )+  )

<rule: digit>
  [\x{30}-\x{39}]

<rule: identifier>
  <unquoted_string> | <quoted_string>

<rule: unquoted_string>
  (?: [\x{41}-\x{5A}] | [\x{61}-\x{7A}] | \x5F (?: [\x{30}-\x{39}] | [\x{41}-\x{5A}] | \x5F | [\x{61}-\x{7A}] )*  )

<rule: quoted_string>
  (?: <quote> (?: <unescaped_char> | <escaped_char> )+ <quote> )

<rule: unescaped_char>
  [\x{20}-\x{21}] | [\x{23}-\x{5B}] | [\x{5D}-\x{10FFFF}]

<rule: escape>
  \x5C

<rule: quote>
  \x22

<rule: escaped_char>
  (?: <escape>\x22 | \x5C | \x2F | \x62 | \x66 | \x6E | \x72 | \x74 | (?: \x75 (?: <HEXDIG> ){4}  ) )

<rule: json_value>
  <false> | <null> | <true> | <json_object> | <json_array> | <json_number> | <json_quoted_string>

<rule: false>
  \x66\x61\x6c\x73\x65

<rule: null>
  \x6e\x75\x6c\x6c

<rule: true>
  \x74\x72\x75\x65

<rule: json_quoted_string>
  (?: \x22 (?: <unescaped_literal> | <escaped_literal> )+ \x22 )

<rule: begin_array>
  (?: <ws>\x5B<ws> )

<rule: begin_object>
  (?: <ws>\x7B<ws> )

<rule: end_array>
  (?: <ws>\x5D<ws> )

<rule: end_object>
  (?: <ws>\x7D<ws> )

<rule: name_separator>
  (?: <ws>\x3A<ws> )

<rule: value_separator>
  (?: <ws>\x2C<ws> )

<token: ws>
   (?: \x20 | \x09 | \x0A | \x0D )* 

<rule: json_object>
  (?: <begin_object> (?: (?: <member> (?: (?: <value_separator><member> ) )*  ) )? <end_object> )

<rule: member>
  (?: <quoted_string><name_separator><json_value> )

<rule: json_array>
  (?: <begin_array> (?: (?: <json_value> (?: (?: <value_separator><json_value> ) )*  ) )? <end_array> )

<rule: json_number>
  (?:  (?: <minus> )? <int> (?: <frac> )?  (?: <exp> )?  )

<rule: decimal_point>
  \x2E

<rule: digit1_9>
  [\x{31}-\x{39}]

<rule: e>
  \x65 | \x45

<rule: exp>
  (?: <e> (?: <minus> | <plus> )?  (?: <digit> )+  )

<rule: frac>
  (?: <decimal_point> (?: <digit> )+  )

<rule: int>
  <zero> | (?: <digit1_9> (?: <digit> )*  )

<rule: minus>
  \x2D

<rule: plus>
  \x2B

<rule: zero>
  \x30
}x;

  if ($input =~ $matcher) {
    my %x = %/;
    use Data::Dumper;
    print Dumper(\%x);
  } else {
    print STDERR "$_\n" for (@!);
  }
}

1;
