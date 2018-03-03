#!perl
# rotate and then crop out the triangles
use File::Basename;
use Math::Trig;
use POSIX;

$image_dir = "d:/incoming/images/2017-12-26";
$dest_dir = "4k";
my $cur_pict = "";
my $image_magic_location = "c:/Program Files/Imagemagick-7.0.2-Q16";
my $full_dest = "$image_dir\\$dest_dir";
my $rotate = -1.7;
my $rotate_rad = deg2rad($rotate);
my @my_dim;
my @my_dim2 = [0,0];
my $my_width = 0;
my $my_height = 0;
my $wr = 1; # Set to an integer so that these get floored when set
my $hr = 1;
my $xr = 1;
my $yr = 1;
my $my_crop1 = "";

# get the jpegs in the directory
@files = <$image_dir/*.jpg>;
unless(-d $full_dest) {
	mkdir $full_dest or die;
}
foreach $cur_file (@files) {
	print "Current file is $cur_file\n";
	($file_base, $dir_name, $file_exteniton) = fileparse($cur_file, ('\.jpg') );

	# Find dimentions and figure out how much to crop after rotation
	# Math from here:
	# https://stackoverflow.com/questions/16702966/rotate-image-and-crop-out-black-borders/16778797#16778797
	$command = '"' . "$image_magic_location\\magick" . '" identify ' . "$cur_file";
	print "command to get dims: $command \n";
	$output = `$command`;
	print "output is: $output \n";
	@my_dim = split(/ /, $output);
	print "third part is: $my_dim[2] \n";
	@my_dim2 = split(/x/, $my_dim[2]);
	$my_width = $my_dim2[0];
	$my_height = $my_dim2[1];
	print "width = $my_width and height = $my_height \n";
	if ($my_width >= $my_height) {
		$side_long = $my_width;
		$side_short = $my_height;
	} else {
		$side_long = $my_height;
		$side_short = $my_width;
	}
	$sin_a = abs(sin($rotate_rad));
	$cos_a = abs(cos($rotate_rad));
	if ($side_short <= 2.0 * $sin_a * $cos_a * $side_long) {
		$x = 0.5 * $side_short;
		if ($my_width >= $my_height) {
			$wr = $x/$sin_a;
			$hr = $x/$cos_a;
		} else {
			$wr = $x/$cos_a;
			$hr = $x/$sin_a;
		}
	} else {
		$cos_2a = $cos_a * $cos_a - $sin_a * $sin_a;
		$wr = ($my_width * $cos_a - $my_height * $sin_a)/$cos_2a;
		$hr = ($my_height * $cos_a - $my_width * $sin_a)/$cos_2a;
	}
	$xr = ceil(($my_width - $wr) / 2.0);
	$yr = ceil(($my_height - $hr) / 2.0);
	print "my four vals are: $wr $hr $xr $yr \n";	$my_crop1 = sprintf("%dx%d+%d+%d", floor($wr), floor($hr), $xr, $yr);	print "my_crop1 is: $my_crop1 \n";	$command = '"' . "$image_magic_location\\magick" . '" ' . 
		'"' . "$cur_file" . '"' . ' -sigmoidal-contrast 2,0% -rotate "' . "$rotate" .
		'"' . " -crop $my_crop1" .
		' -resize "3840x2160^", -gravity Center -crop 3840x2160+0+0 +repage ' .  
		"$full_dest" . "\\" . "$file_base" . ".jpg" . '"';
	print "$command\n";
	
	# will need to call image magic
	$output = `$command`;
	
	print $output;
}
exit(0);