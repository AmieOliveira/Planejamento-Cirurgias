#!/usr/bin/perl 
##      ---------------------------------------------------------------
##
##     	tttplots-compare: A perl program to compare time-to-target plots 
##      or general runtime distributions
##
##      usage: perl tttplots-compare -f <input-file1> <input-file2>
##
##             where <input-file>.dat is the input file of time to
##                   target values (one per line).
##
##      authors: Celso C. Ribeiro and Isabel Rosseti.
##
##      ---------------------------------------------------------------


##      ----------------------------------------------------------------
##      Input network and spec file names.
##      ----------------------------------------------------------------
	$datafilethere=0;
	while ($ARGV[0]) {
		if ($ARGV[0] eq "-f") {
			shift(@ARGV);
			$filename = $ARGV[0];
			$datafilename1 = $filename . ".dat";
			shift(@ARGV);
			$filename = $ARGV[0];
			$datafilename2 = $filename . ".dat";
			$datafilethere=2;
			shift;
		}

	}
	if ($datafilethere == 0) {
		die "Error, data file missing. \n
		     Usage: perl tttplots-compare.pl -f <input-file1> <input-file2> \n";
	}


##      ----------------------------------------------------------------
#	Open data file1, read data and close it. 
##      ----------------------------------------------------------------
	open (DATFILE,$datafilename1) || die "Cannot open file: $datafilename1 \n";

	$n1=0;
	while ($line = <DATFILE>){
		chomp($line);
		@field = split(/\s+/,$line);

		$nfields=0;                 #
		foreach $fld (@field){      # count number of fields
			$nfields++;         #
		}                           # 

		if ($nfields != 1){
			die "Number of fields in data file must be 1 \n";
		}
		$time_value1[$n1] = $field[0];
		$n1++;
	}
	close (DATFILE);


##      ----------------------------------------------------------------
#	Open data file2, read data and close it. 
##      ----------------------------------------------------------------
	open (DATFILE,$datafilename2) || die "Cannot open file: $datafilename2 \n";

	$n2=0;
	while ($line = <DATFILE>){
		chomp($line);
		@field = split(/\s+/,$line);

		$nfields=0;                 #
		foreach $fld (@field){      # count number of fields
			$nfields++;         #
		}                           # 

		if ($nfields != 1){
			die "Number of fields in data file must be 1 \n";
		}
		$time_value2[$n2] = $field[0];
		$n2++;
	}
	close (DATFILE);


##      ----------------------------------------------------------------
#	Sort times.
##      ----------------------------------------------------------------
	@sorted_time_value1 = sort { $a <=> $b } @time_value1;
	@sorted_time_value2 = sort { $a <=> $b } @time_value2;

	print "\@--------------------------------------------------------@\n";
	print " Input data set > \n\n";
	print "     data file   : $datafilename1 \n";
	print "     data points : $n1 \n\n";
	print "     data file   : $datafilename2 \n";
	print "     data points : $n2 \n";

##	----------------------------------------------------------------------
#	Compute probability
##	----------------------------------------------------------------------
	print "\@--------------------------------------------------------@\n";
	print " Computing probability >\n";


##	----------------------------------------------------------------------
#	Definition of the program constants
##	----------------------------------------------------------------------
	use constant INITIAL_VALUE_H => 1;
	use constant ERROR => 0.001;
	use constant NUMBER_ITERATIONS => 20;

##	----------------------------------------------------------------------
#	Definition of the upper bound T
##	----------------------------------------------------------------------
        if($sorted_time_value1[$n1 - 1] >= $sorted_time_value2[$n2 - 1]){
	  $T = $sorted_time_value1[$n1 - 1];
        } 
        else {
	  $T = $sorted_time_value2[$n2 - 1];
	}

##	----------------------------------------------------------------------
#	Definition of the lower bound t
##	----------------------------------------------------------------------
        if($sorted_time_value1[0] <= $sorted_time_value2[0]){
	  $t = $sorted_time_value1[0];
        } 
        else {
	  $t = $sorted_time_value2[0];
	}

##	----------------------------------------------------------------------
#	Definition of the initial values of h, iter, and flag
##	----------------------------------------------------------------------
	$h = INITIAL_VALUE_H;
	$iter = 0;
	$flag = 0;

	while($flag == 0){
##	----------------------------------------------------------------------
#	Update iter, delta, L, and R
##	----------------------------------------------------------------------
	  $iter++;
	  $delta = ($T - $t) / $h;    
	  $L = 0.0;
	  $R = 0.0;

##	----------------------------------------------------------------------
#	Compute F1_(i*delta) and F1_((i+1)*delta)
##	----------------------------------------------------------------------
          $m_dif = 0;
	  for($i = 0; $i < $h; $i++){
     	     $F1_idelta = 0;
	     $F1_i1delta = 0;

             for($j = 0; $j < $n1; $j++){
               if($sorted_time_value1[$j] <= ($t + ($i * $delta))){
                 $F1_idelta++;
               }

               if($sorted_time_value1[$j] <= ($t + (($i + 1) * $delta))){
                 $F1_i1delta++;
               }
             }

##	----------------------------------------------------------------------
#	Compute the greatest difference between F1's
##	----------------------------------------------------------------------
             if($m_dif < ($F1_i1delta - $F1_idelta)){
               $m_dif = $F1_i1delta - $F1_idelta;
             }

             $f2_idelta = 0;
	     $f2_i1delta = 0;

##	----------------------------------------------------------------------
#	Compute f2_(i*delta) and f2_((i+1)*delta)
##	----------------------------------------------------------------------
             for($j = 0; $j < $n2; $j++){
               if($sorted_time_value2[$j] <= ($t + ($i * $delta))){
                 $f2_idelta++;
               }

               if($sorted_time_value2[$j] <= ($t + (($i + 1) * $delta))){
                 $f2_i1delta++;
               }
             }

             $f2_div_n = ($f2_i1delta - $f2_idelta) / ($n2 * 1.0);

##	----------------------------------------------------------------------
#	Compute L and R
##	----------------------------------------------------------------------
             $L = $L + (($f2_div_n * $F1_idelta) / ($n1 * 1.0));
      	     $R = $R + (($f2_div_n * $F1_i1delta) / ($n1 * 1.0)); 
	  }

##	----------------------------------------------------------------------
#	Compute error, error_(i*delta), and prob
##	----------------------------------------------------------------------
	  $error_RL = $R - $L;
   	  $error_idelta = (1.0 * $m_dif) / (1.0 * $n1);
	  $prob = ($L + $R) / 2.0;

##	----------------------------------------------------------------------
#	Test of the stopping criterion
##	----------------------------------------------------------------------
	  if(($error_RL <= ERROR) || ($iter > NUMBER_ITERATIONS)){
            $flag = 1;
          }
          else{
            $h = $h * 2;
          }
	}
        
##	----------------------------------------------------------------------
#	Print of the results
##	----------------------------------------------------------------------
	print "\@--------------------------------------------------------@\n";
        print " Result > \n\n";
	print "      P(x1 <= x2) = $prob \n";
	print "\n DONE \n";
	print "\@--------------------------------------------------------@\n";
        print "\n";
