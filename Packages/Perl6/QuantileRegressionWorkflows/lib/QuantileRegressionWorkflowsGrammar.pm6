#==============================================================================
#
#   Quantile Regression workflows grammar in Raku Perl 6
#   Copyright (C) 2019  Anton Antonov
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#   Written by Anton Antonov,
#   antononcube @ gmai l . c om,
#   Windermere, Florida, USA.
#
#==============================================================================
#
#   For more details about Raku Perl6 see https://perl6.org/ .
#
#==============================================================================
#
#  The grammar design in this file follows very closely the EBNF grammar
#  for Mathematica in the GitHub file:
#    https://github.com/antononcube/ConversationalAgents/blob/master/EBNF/English/Mathematica/QuantileRegressionWorkflowsGrammar.m
#
#==============================================================================

use v6;
unit module QuantileRegressionWorkflowsGrammar;

        # This role class has common command parts.
role QuantileRegressionWorkflowsGrammar::CommonParts {

    # Speech parts
    token do-verb { 'do' }
    token with-preposition { 'using' | 'with' | 'by' }
    token using-preposition { 'using' | 'with' | 'over' }
    token by-preposition { 'by' | 'with' | 'using' }
    token for-preposition { 'for' | 'with' }
    token of-preposition { 'of' }
    token from-preposition { 'from' }
    token to-preposition { 'to' | 'into' }
    token assign { 'assign' | 'set' }
    token a-determiner { 'a' | 'an'}
    token and-conjuction { 'and' }
    token the-determiner { 'the' }
    rule for-which-phrase { 'for' 'which' | 'that' 'adhere' 'to' }
    rule number-of { [ 'number' | 'count' ] 'of' }
    token per { 'per' }
    token results { 'results' }
    token simple { 'simple' | 'direct' }
    token use-verb { 'use' | 'utilize' }
    token get-verb { 'obtain' | 'get' | 'take' }
    token object { 'object' }

    # Data
    token records { 'rows' | 'records' }
    rule time-series-data { 'time' 'series' 'data'? }
    rule data-frame { 'data' 'frame' }
    rule data { <data-frame> | 'data' | 'dataset' | <time-series-data> }
    token dataset-name { ([ \w | '_' | '-' | '.' | \d ]+) <!{ $0 eq 'and' }> }
    token variable-name { ([ \w | '_' | '-' | '.' | \d ]+) <!{ $0 eq 'and' }> }

    # Directives
    rule load-data-directive { ( 'load' | 'ingest' ) <.the-determiner>? <data> }
    token create-directive { 'create' | 'make' }
    token generate-directive { 'generate' | 'create' | 'make' }
    token compute-directive { 'compute' | 'find' | 'calculate' }
    token display-directive { 'display' | 'show' | 'echo' }
    rule compute-and-display { <compute-directive> [ 'and' <display-directive> ]? }
    token diagram { 'plot' | 'plots' | 'graph' | 'chart' }
    token plot-directive { 'plot' | 'chart' | <display-directive> <diagram> }
    rule use-directive { [ <get-verb> <and-conjuction>? ]? <use-verb> }
    token classify { 'classify' }

    # Value types
    token number-value { (\d+ ['.' \d*]?  [ [e|E] \d+]?) }
    token integer-value { \d+ }
    token percent { '%' | 'percent' }
    token percent-value { <number-value> <.percent> }
    token boolean-value { 'True' | 'False' | 'true' | 'false' }

    # Time series and regression specific
    token error { 'error' | 'errors' }
    token outliers { 'outliers' | 'outlier' }
    rule the-outliers { <the-determiner> <outliers> }
    token ingest { 'ingest' | 'load' | 'use' | 'get' }
    token fit { 'fit' | 'fitting' }
    token quantile { 'quantile' }
    token quantiles { 'quantiles' }
    token probability { 'probability' }
    token probabilities { 'probabilities' }
    rule qr-object { [ 'qr' | 'quantile' 'regression' ]? 'object' }

    # Lists of things
    token list-separator-symbol { ',' | '&' | 'and' | ',' 'and' }
    token list-separator { <.ws>? <list-separator-symbol> <.ws>? }
    token list { 'list' }

    # Number list
    rule number-value-list { <number-value>+ % <list-separator>? }

    rule range-spec-step { <with-preposition>? 'step' | <with-preposition> }
    rule range-spec { [ <.from-preposition> <number-value> ] [ <.to-preposition> <number-value> ] [ <.range-spec-step> <number-value> ]? }

    # Expressions
    token wl-expr { \S+ }

    # Error message
    # method error($msg) {
    #   my $parsed = self.target.substr(0, self.pos).trim-trailing;
    #   my $context = $parsed.substr($parsed.chars - 15 max 0) ~ '⏏' ~ self.target.substr($parsed.chars, 15);
    #   my $line-no = $parsed.lines.elems;
    #   die "Cannot parse code: $msg\n" ~ "at line $line-no, around " ~ $context.perl ~ "\n(error location indicated by ⏏)\n";
    # }

    method ws() {
      if self.pos > $*HIGHWATER {
        $*HIGHWATER = self.pos;
        $*LASTRULE = callframe(1).code.name;
      }
      callsame;
    }

    method parse($target, |c) {
      my $*HIGHWATER = 0;
      my $*LASTRULE;
      my $match = callsame;
      self.error_msg($target) unless $match;
      return $match;
    }

    method error_msg($target) {
      my $parsed = $target.substr(0, $*HIGHWATER).trim-trailing;
      my $un-parsed = $target.substr($*HIGHWATER, $target.chars).trim-trailing;
      my $line-no = $parsed.lines.elems;
      my $msg = "Cannot parse the command";
      # say 'un-parsed : ', $un-parsed;
      # say '$*LASTRULE : ', $*LASTRULE;
      $msg ~= "; error in rule $*LASTRULE at line $line-no" if $*LASTRULE;
      $msg ~= "; target '$target' position $*HIGHWATER";
      $msg ~= "; parsed '$parsed', un-parsed '$un-parsed'";
      $msg ~= ' .';
      die $msg;
    }

}

grammar QuantileRegressionWorkflowsGrammar::Quantile-regression-workflow-commmand does CommonParts {
    # TOP
    rule TOP { <data-load-command> | <create-command> |
               <data-transformation-command> | <data-statistics-command> |
               <regression-command> |
               <find-outliers-command> | <plot-command> }

    # Load data
    rule data-load-command { <load-data> | <use-qr-object> }
    rule data-location-spec { <dataset-name> }
    rule load-data { <.load-data-directive> <data-location-spec> }
    rule use-qr-object { <.use-verb> <.the-determiner>? <.qr-object> <variable-name> }

    # Create command
    rule create-command { <create-by-dataset> }
    rule create-simple { <create-directive> <.a-determiner>? <object> <simple-way-phrase> | <simple> <object> [ 'creation' | 'making' ] }
    rule create-by-dataset { [ <create-simple> | <create-directive> ] [ <.by-preposition> | <.with-preposition> | <.from-preposition> ]? <dataset-name> }

    # Data transform command
    rule data-transformation-command { <delete-missing> | <rescale-command> | <resample-command> | <moving-func-command> }

    rule delete-missing { [ 'delete' | 'drop' | 'erase' ] [ 'rows' <.with-preposition> ]? 'missing' [ 'values' ]? }

    rule rescale-command { <rescale-axis> | <rescale-both-axes> }
    rule rescale-axis {'rescale' <.the-determiner>? <axis-spec> 'axis'}
    rule axis-spec { <regressor-axis-spec> | <value-axis-spec> }
    rule regressor-axis-spec { 'x' | 'regressor' }
    rule value-axis-spec { 'y' | 'value' }
    rule rescale-both-axes {'rescale' [ <the-determiner> | 'both' ]? 'axes'}

    rule resample-command {'resample' <.the-determiner>? [ <time-series-data> ]? [ <using-preposition> <resampling-method-spec> ]? [ <using-preposition> <sampling-step-spec> ]?}
    rule sampling-step-spec { <default-sampling-step> | 'step' <number-value> }
    rule default-sampling-step { [ 'smallest' 'difference' | 'default' | 'automatic' ] 'step'}
    rule resampling-method-spec { <resampling-method> | <resampling-method-name> }
    rule resampling-method {[ 'LinearInterpolation' | 'HoldValueFromLeft' ]}
    rule resampling-method-name { 'linear' 'interpolation' | 'hold' 'value' 'from' 'left' }

    rule moving-func-command { [ <.compute-directive>? <moving-func-spec> <.using-preposition> ] [ <number-value> [ 'elements' ]? | [ 'the' ]? [ 'weights' ]? <number-value-list> [ 'weights' ]? ]}
    rule moving-func-name { 'moving' [ 'average' | 'median' | 'Mean' | 'Median' ] }
    rule moving-map-func { ['moving' 'map'] <wl-expr>}
    rule moving-func-spec { <moving-func-name> | <moving-map-func> }

    # Data statistics command
    rule data-statistics-command { <summarize-data> }
    rule summarize-data { 'summarize' <.the-determiner>? <data> | <display-directive> <data>? ( 'summary' | 'summaries' ) }

    # Regression command
    rule regression-command { [ <.compute-directive> | <.compute-and-display> | <.do-verb> ] <quantile-regression-spec> }
    rule quantile-regression { 'quantile' 'regression' | 'QuantileRegression' }
    rule quantile-regression-phrase { <.a-determiner>? <quantile-regression> <.fit>? }
    rule quantile-regression-spec { <quantile-regression-spec-full> | <quantile-regression-spec-simple> }
    rule quantile-regression-spec-simple { <quantile-regression-phrase> }
    rule quantile-regression-spec-full { <quantile-regression-phrase> [ <.using-preposition> | <.for-preposition> ] <quantile-regression-spec-element-list> }
    rule quantile-regression-spec-element-list { <quantile-regression-spec-element>+ % <spec-list-delimiter> }
    rule quantile-regression-spec-element { <probabilities-spec-phrase> | <knots-spec-phrase> | <interpolation-order-spec-phrase> }

    token spec-list-delimiter { <list-separator> <.ws>? <.using-preposition>? }

    # QR elenent - list of probabilities.
    rule probabilities-spec-phrase {  <.the-determiner>? [ <.probabilities-list> <probabilities-spec> | <probabilities-spec> <.probabilities-list>? ] }
    rule probabilities-list {  <probabilities> | <probability> <list>? | <probability> }
    rule probabilities-spec { <number-value-list> | <range-spec> }

    # QR element -- knots.
    rule knots-spec-phrase { <.knots> <knots-spec> | <knots-spec> <.knots> }
    rule knots { <the-determiner>? 'knots' }
    rule knots-spec { <integer-value> | <number-value-list> | <range-spec> }

    # QR element -- interpolation order.
    rule interpolation-order-spec-phrase { <.interpolation-order> <interpolation-order-spec> | <interpolation-order-spec> <.interpolation-order> }
    rule interpolation-order { 'interpolation' [ 'order' | 'degree' ] }
    rule interpolation-order-spec { <integer-value> }

    # Find outliers command
    rule find-outliers-command { <find-type-outliers> | <find-outliers-spec> | <find-outliers-simple> }
    rule outliers-phrase { <the-determiner>? <data>? <outliers> }
    rule find-outliers-simple { <compute-and-display> <.outliers-phrase> }

    rule outlier-type { [ <.the-determiner>? <.data>? ] ( 'top' | 'bottom' ) }

    rule the-quantile { <the-determiner>? <quantile> }
    rule the-quantiles { <the-determiner>? <quantiles> }

    rule the-probability { <the-determiner>? <probability> }
    rule the-probabilities { <the-determiner>? <probabilities> }

    rule find-type-outliers { <.compute-and-display> <outlier-type> <.outliers-phrase> [ <.with-preposition> [ <probabilities-spec> | <probabilities-spec-phrase> ] ]? }
    rule find-outliers-spec { <.compute-and-display> <.outliers-phrase> <.with-preposition> [ <probabilities-spec> | <probabilities-spec-phrase> ] }

    # Plot command
    rule plot-command { <display-directive> <plot-elements-list>? [ <date-list-diagram> | <diagram> ] | <diagram> };
    rule plot-elements-list { [ <diagram-type> | <data> ]+  % <list-separator> }
    rule diagram-type { <regression-curve-spec> | <error> | <outliers> };
    rule regression-curve-spec { ['fitted']? ( <regression-function> | <regression-function-name> ) [ 'curve' | 'curves' | 'function' | 'functions' ]? }
    rule date-list-phrase { [ 'date' | 'dates' ]  ['list']? }
    rule date-list-diagram { ( <date-list-phrase>?  <diagram> ) | <diagram> [ <with-preposition> [ 'dates' | 'date' 'axis' ] ] }

    rule regression-function-list { [ <regression-function> | <regression-function-name> ]+ % <list-separator> }
    rule regression-function { 'QuantileRegression' | 'QuantileRegressionFit' | 'LeastSquares' }
    rule regression-function-name { 'quantile' ['regression']? | 'least' 'squares' ['regression']? }
}
