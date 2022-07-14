package HTML;

use strict;
use warnings;
use autodie;
use File::Basename;
use Sys::Hostname;
use JSON::XS;
use Fcntl qw(:flock SEEK_END);    # import LOCK_* and SEEK_END constants

#use Geo::IP;
use IO::Compress::Gzip qw(gzip $GzipError);
use List::Util qw(max);

=head1 NAME

  BROWSER::HTML - Package for HTML generation

=head1 SYNOPSIS

  use BROWSER::HTML

=head1 DESCRIPTION


=head1 AUTHOR

Written by Manuel Rueda, PhD

=cut

# Defining a few variables below. Naming convention: snake_case
my $version     = '0.4.0';
my $server_dir  = '.';
my $host        = hostname;
my $server_ip   = $host eq 'mrueda-ws1' ? 'localhost' : '10.40.129.44';
my $http_server = "http://$server_ip:81";
my $job_id  = time . substr( "00000$$", -5 );     # temporary Id for the job
my $job_dir = $server_dir . '/data/' . $job_id;
my $gnomAD  = 1;
my $PDB     = 0;

my $logo =

  #"<img alt=\"SRTI\" width=\"250\" data-sticky-width=\"200\" data-sticky-height=\"40\" src=\"img/stsi-logo.gif\">";
"<img alt=\"SRTI\" width=\"400\" data-sticky-width=\"300\" src=\"img/scripps-logo_black.png\">";

sub new {

    my ( $class, $arg ) = @_;
    my $self = {
        query  => $arg->{query},
        cohort => $arg->{cohort},
        format => $arg->{format},
        allele => $arg->{allele}
    };

    bless $self, $class;
    return $self;
}

sub submission {

    my $self = shift;
    my $query  = $self->{query};
    my $allele = $self->{allele};
    my $str    = '';
    $str .= html_header();
    $str .= html_results( $query, $allele );
    $str .= html_footer();
    return $str;
}

sub front_page {

    my $str = '';
    $str .= html_header('home');
    $str .= html_form();
    $str .= html_body();
    $str .= html_footer();
    return $str;
}

sub beacon_page {

    my $str = '';
    $str .= html_header('ga4gh');
    $str .= beacon_form();
    $str .= html_footer();
    return $str;
}

#############################################

=head2 html_form

    About   : 
    Usage   : None             
    Args    : 

=cut

#############################################

sub html_form {

    my $str = '';
    $str .= '
      <div id="web-form" class="jumbotron" style="display:none;">
       <div class="container form-group">
         <form method="post" action="results" enctype="application/x-www-form-urlencoded" name="browser-parameters">
          <b>Search for a region, gene, or dbSNP id</b><br /> Examples: <a href="results?query=14:28986157-29040304">14:28986157-29040304</a>, <a href="results?query=ACE2">ACE2</a>, <a href="results?query=rs12255372">rs12255372</a></label><input name="query" class="col-md-12" id="query" type="textfield"/>
      </div>
      <hr />
      <input type="submit" name="submit-btn" value="Submit" class="btn btn-primary btn-lg hidden" id="submit-btn" />
      </form></div></div>';

    return $str;
}

#############################################

=head2 html_header

    About   : 
    Usage   : None             
    Args    : 

=cut

#############################################

sub html_header {

    my $active = shift // '';

    #my $auto_complete = _jQuery_autocomplete();
    my $auto_complete = '';
    my $dataTables    = dataTables_js();
    my $str           = << "EOF";
<!DOCTYPE html>
<html lang="en">
<head>

<!-- Basic -->
<meta charset="utf-8">
<title>SRTI Variant Browser</title>		
<meta name="keywords" content="HTML5" />
<meta name="description" content="SRTI Variant Browser">
<meta name="author" content="mrueda\@scripps.edu">
<link rel="icon" href="img/favicon.ico" type="image/x-icon" />

<!-- Mobile Metas -->
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<!-- Mobile Metas -->
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<!-- Web Fonts  -->
<link href="//fonts.googleapis.com/css?family=Open+Sans:300,400,600,700,800%7CShadows+Into+Light" rel="stylesheet" type="text/css">

<!-- Libs CSS -->
<link rel="stylesheet" href="css/bootstrap.min.css">
<link rel="stylesheet" href="vendor/font-awesome/css/font-awesome.css">
<link rel="stylesheet" href="vendor/owl-carousel/owl.carousel.css" media="screen">
<link rel="stylesheet" href="vendor/owl-carousel/owl.theme.css" media="screen">
<link rel="stylesheet" href="vendor/magnific-popup/magnific-popup.css" media="screen">
<link rel="stylesheet" href="vendor/isotope/jquery.isotope.css" media="screen">
<link rel="stylesheet" href="vendor/mediaelement/mediaelementplayer.css" media="screen">

<!-- Theme CSS -->
<link rel="stylesheet" href="css/theme.css">
<link rel="stylesheet" href="css/theme-elements.css">
<link rel="stylesheet" href="css/theme-blog.css">
<link rel="stylesheet" href="css/theme-shop.css">
<link rel="stylesheet" href="css/theme-animate.css">

<!-- Current Page CSS -->
<link rel="stylesheet" href="vendor/rs-plugin/css/settings.css" media="screen">
<link rel="stylesheet" href="vendor/circle-flip-slideshow/css/component.css" media="screen">

<!-- Responsive CSS -->
<link rel="stylesheet" href="css/theme-responsive.css" />

<!-- Skin CSS -->
<link rel="stylesheet" href="css/skins/default.css">

<!-- Custom CSS -->
<link rel="stylesheet" href="css/custom.css">

<!-- SRTI CSS -->
<link rel="stylesheet" href="css/main.css">

<!-- Head Libs -->
<script src="vendor/modernizr.js"></script>

<!--[if IE]>
<link rel="stylesheet" href="css/ie.css">
<![endif]-->

<!--[if lte IE 8]>
	<script src="vendor/respond.js"></script>
<![endif]-->
               
<!-- Styles -->
<link rel="stylesheet" type="text/css" href="jsD/media/css/jquery.dataTables.min.css">
<link rel="stylesheet" type="text/css" href="jsD/media/css/dataTables.colReorder.css">
<link rel="stylesheet" type="text/css" href="jsD/media/css/dataTables.colVis.css">
<link rel="stylesheet" type="text/css" href="jsD/media/css/dataTables.tableTools.css">
<link rel="stylesheet" type="text/css" href="jsD/resources/syntax/shCore.css">

<script src="vendor/jquery.js"></script>
<script src="js/main.js"></script>
<script src="jsD/media/js/jquery.dataTables.min.js"></script>
<script src="jsD/media/js/dataTables.colReorder.js"></script>
<script src="jsD/media/js/dataTables.colVis.js"></script>
<script src="jsD/media/js/dataTables.tableTools.js"></script>
<script src="jsD/resources/syntax/shCore.js"></script>
<script src="jsD/resources/demo.js"></script>
<script src="js/jqBootstrapValidation.js"></script>
<script src="jsD/media/js/d3.v3.min.js" charset="utf-8"></script>
<script src="jsD/media/js/d3.layout.cloud.js"></script>

$auto_complete
$dataTables

</head>
	<body>

		<div class="body">
			<header id="header">
				<div class="container">
					<h1 class="logo">
                                                <a href="http://scripps.edu">
							$logo
                                                        
						</a>
					</h1>
					<div class="search">
						<form id="searchForm" action="page-search-results.html" method="get">
							<div class="input-group">
								<input type="text" class="form-control search" name="q" id="q" placeholder="Site search...">
								<span class="input-group-btn">
									<button class="btn btn-default" type="submit"><i class="icon icon-search"></i></button>
								</span>
							</div>
						</form>
					</div>
					<nav>
						<ul class="nav nav-pills nav-top">
							<li class="phone">
								<span><i class="icon icon-phone"></i> (858) 554-5708</span>
							</li>
						</ul>
					</nav>
					<button class="btn btn-responsive-nav btn-inverse" data-toggle="collapse" data-target=".nav-main-collapse">
						<i class="icon icon-bars"></i>
					</button>
				</div>
				<div class="navbar-collapse nav-main-collapse collapse">
					<div class="container">
						<ul class="social-icons">
							<li class="facebook"><a href="https://www.facebook.com/ScrippsResearchInstitute" target="_blank" title="Facebook">Facebook</a></li>
							<li class="linkedin"><a href="https://www.linkedin.com/school/the-scripps-research-institute" target="_blank" title="Linkedin">Linkedin</a></li>
						</ul>
						<nav class="nav-main mega-menu">
							<ul class="nav nav-pills nav-main" id="mainMenu">
EOF
    $str .= $active eq 'home' ? "<li class=\"active\">" : '<li>';
    $str .= << "EOF";

                                       
                                                                        <a href="$http_server"><i class="icon icon-home"></i>Home</a>
                                                                </li>
EOF
    $str .= $active eq 'ga4gh' ? "<li class=\"active\">" : '<li>';
    $str .= << "EOF";
                                                                        <a href="ga4gh">GA4GH</a>
                                                                </li>
                                                                <li>
                                                                        <a href="page-help.html">Help</a>
                                                                </li>
                                                                <li>
                                                                        <a href="page-faq.html">FAQ</a>
                                                                </li>

								<li class="dropdown">
									<a class="dropdown-toggle" href="#">
										Contact Us
										<i class="icon icon-angle-down"></i>
									</a>
									<ul class="dropdown-menu">
										<li><a href="contact-us.html">SRTI</a></li>
									</ul>
								</li>
							</ul>
						</nav>
					</div>
				</div>
			</header>

EOF
    return $str;
}

#############################################

=head2 html_body

    About   : 
    Usage   : None             
    Args    : 

=cut

#############################################

sub html_body {

    # Extracted from bootstrap
    my $str = '';

    #  <div class="slider" id="revolutionSlider">
    $str = << "EOF";


			<div id="browser-body" role="main" class="main">

				<div class="slider-container light">
					<div class="" id="revolutionSlider">
						<ul>
							<li data-transition="fade" data-slotamount="13" data-masterspeed="300" >

								<img src="img/slides/slide-bg-light.jpg" data-bgfit="cover" data-bgposition="center center" data-bgrepeat="no-repeat">

								<div class="tp-caption sft stb visible-lg"
									 data-x="32"
									 data-y="80"
									 data-speed="300"
									 data-start="1000"
									 data-easing="easeOutExpo"><img src="img/slides/slide-title-border-light.png" alt=""></div>

								<div class="tp-caption top-label lfl stl"
									 data-x="102"
									 data-y="80"
									 data-speed="300"
									 data-start="500"
									 data-easing="easeOutExpo">Welcome to SRTI's</div>

								<div class="tp-caption sft stb visible-lg"
									 data-x="332"
									 data-y="80"
									 data-speed="300"
									 data-start="1000"
									 data-easing="easeOutExpo"><img src="img/slides/slide-title-border-light.png" alt=""></div>

								<div class="tp-caption main-label sft stb"
									 data-x="10"
									 data-y="130"
									 data-speed="300"
									 data-start="1500"
									 data-easing="easeOutExpo">VARIANT BROWSER</div>

								<div class="tp-caption bottom-label sft stb"
									 data-x="50"
									 data-y="220"
									 data-speed="500"
									 data-start="2000"
									 data-easing="easeOutExpo">Beta Version</div>
                                                                <div class="tp-caption sfb"
									 data-x="720"
									 data-y="90"
									 data-speed="500"
									 data-start="2500"
									 data-easing="easeOutBack"><img width="240px" src="img/diabetes-1.jpg" alt=""></div>


							</li>
						</ul>
					</div>
				</div>

				<div class="home-intro light">
					<div class="container">

						<div class="row">
							<div class="col-md-8">
								<p>
									SRTI resource to browse aggregate data for the Welderly and Molecular Autopsy studies 
									<span>Complete Genomics and Illumina technologies</span>
								</p>
							</div>
							<div class="col-md-4">
								<div class="get-started">
									<a id="start-search-btn" href="#" class="btn btn-lg btn-primary">Start browsing!</a>
								</div>
							</div>
						</div>

					</div>
				</div>

				<div class="container">
					<div class="row">
						<div class="col-md-4">
							<div class="feature-box">
								<div class="feature-box-icon">
									<i class="icon icon-bars"></i>
								</div>
								<div class="feature-box-info">
									<h4 class="shorter">SRTI</h4>
									<p class="tall">The mission of the Scripps Research Translational Institute is to accelerate translational and clinical research to impact human health, by combining the exceptional lineage of basic and translational science.</p>
								</div>
							</div>
						</div>
						<div class="col-md-4">
							<div class="feature-box">
								<div class="feature-box-icon">
									<i class="icon icon-desktop"></i>
								</div>
								<div class="feature-box-info">
									<h4 class="shorter">Genomics</h4>
									<p class="tall">The Scripps Research Translational Institute carries out clinical studies on Genomics with potential for driving progress in individualized medicine.</p>
								</div>
							</div>
						</div>
                                                <div class="col-md-4">
                                                        <div class="feature-box">
                                                                <div class="feature-box-icon">
                                                                        <i class="icon icon-user"></i>
                                                                </div>
                                                                <div class="feature-box-info">
                                                                        <h4 class="shorter">The Wellderly</h4>
                                                                         <p class="tall">We pursued whole genome sequencing of a cohort of individuals who are >80 years old with no chronic diseases to understand the genetics of disease-free aging without medical intervention.</p>
                                                                                                                                       
                                                                </div>
                                                        </div>
                                                </div>

					</div>

				</div>
			</div>
EOF
    return $str;
}

#############################################

=head2 html_footer

    About   : 
    Usage   : None             
    Args    : 

=cut

#############################################

sub html_footer {

    my $str = '';
    $str = << "EOF";

			<footer id="footer">
				<div class="container">
					<div class="row">
						<div class="footer-ribbon">
							<span>Get in Touch</span>
						</div>
						<div class="col-md-3">
							<div class="newsletter">
								<h4>Newsletter</h4>
								<p>Keep up with our latest advances in research. Subscribe to our newsletter</p>
			
								<div class="alert alert-success hidden" id="newsletterSuccess">
									<strong>Success!</strong> You've been added to our email list.
								</div>
			
								<div class="alert alert-danger hidden" id="newsletterError"></div>
			
								<form id="newsletterForm" action="php/newsletter-subscribe.php" method="POST">
									<div class="input-group">
										<input class="form-control" placeholder="Email Address" name="newsletterEmail" id="newsletterEmail" type="text">
										<span class="input-group-btn">
											<button class="btn btn-default" type="submit">Go!</button>
										</span>
									</div>
								</form>
							</div>
						</div>
						<div class="col-md-3">
						</div>
						<div class="col-md-4">
							<div class="contact-details">
								<h4>Contact Us</h4>
								<ul class="contact">
									<li><p><i class="icon icon-map-marker"></i> <strong>Address:</strong> &nbsp;3344 North Torrey Pines Court Suite 300, La Jolla, CA 92037</p></li>
									<li><p><i class="icon icon-phone"></i> <strong>Phone:</strong> (858) 554-5708</p></li>
									<li><p><i class="icon icon-envelope"></i> <strong>Email:</strong> <a href="mailto:genomics\@scripps.edu">genomics\@scripps.edu</a></p></li>
								</ul>
							</div>
						</div>
						<div class="col-md-2">
							<h4>Follow Us</h4>
							<div class="social-icons">
								<ul class="social-icons">
                                                       <li class="facebook"><a href="https://www.facebook.com/ScrippsResearchInstitute" target="_blank" title="Facebook">Facebook</a></li>
                                                        <li class="linkedin"><a href="https://www.linkedin.com/school/the-scripps-research-institute" target="_blank" title="Linkedin">Linkedin</a></li>
								</ul>
							</div>
						</div>
					</div>
				</div>

				<div class="footer-copyright">
					<div class="container">
						<div class="row">
							<div class="col-md-7">
								<p>&copy; Copyright SRTI 2017. All Rights Reserved.</p>
							</div>
							<div class="col-md-4">
								<nav id="sub-menu">
									<ul>
										<li><a href="page-faq.html">FAQ's</a></li>
										<li><a href="contact-us.html">Contact</a></li>
									</ul>
								</nav>
							</div>
						</div>
					</div>
				</div>
			</footer>
		</div>

               <!-- Libs -->
                <script src="vendor/jquery.appear.js"></script>
                <script src="vendor/jquery.easing.js"></script>
                <script src="vendor/jquery.cookie.js"></script>
                <script src="vendor/bootstrap/js/bootstrap.js"></script>
                <script src="vendor/jquery.validate.js"></script>
                <script src="vendor/jquery.stellar.js"></script>
                <script src="vendor/jquery.knob.js"></script>
                <script src="vendor/jquery.gmap.js"></script>
                <script src="vendor/isotope/jquery.isotope.js"></script>
                <script src="vendor/owl-carousel/owl.carousel.js"></script>
                <script src="vendor/jflickrfeed/jflickrfeed.js"></script>
                <script src="vendor/magnific-popup/magnific-popup.js"></script>
                <script src="vendor/mediaelement/mediaelement-and-player.js"></script>
                
                <!-- Theme Initializer -->
                <script src="js/theme.plugins.js"></script>
                <script src="js/theme.js"></script>
                
                <!-- Current Page JS -->
                <script src="js/main.js"></script>
                <script src="vendor/rs-plugin/js/jquery.themepunch.plugins.min.js"></script>
                <script src="vendor/rs-plugin/js/jquery.themepunch.revolution.js"></script>
                <script src="vendor/circle-flip-slideshow/js/jquery.flipshow.js"></script>
                <script src="js/views/view.home.js"></script>
                
                <!-- Custom JS -->
                <script src="js/custom.js"></script>
EOF

    $str .= google_analytics();
    $str .= << "EOF";

	</body>
</html>

EOF
    return $str;
}

#############################################

=head2 html_results

    About   : 
    Usage   : None             
    Args    : 

=cut

#############################################

sub html_results {

    my $query  = shift;
    my $allele = shift;
    print_log( $query, 1 );
    mkdir $job_dir, 0755;
    my $table = html_table( $query, $allele );
    my $str   = '';
    $str .= $logo;
    $str = << "EOF";
    <div role="main" class="main">
    <div id ="results-div">
    <br />
    <!-- Main jumbotron for a primary marketing message or call to action -->
    <div id="browser-jumbotron" class="main">
      <div class="container">
        $table
      </div>
    </div>
   </div>
   </div>
EOF
    $str .= html_form();
    return $str;
}

#############################################

=head2 google_analytics

    About   : 
    Usage   : None             
    Args    : 

=cut

#############################################

sub google_analytics {

    my $str = " 
<!-- Google Analytics: -->
<script>
  (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
  (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
  m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
  })(window,document,'script','//www.google-analytics.com/analytics.js','ga');

  ga('create', 'UA-71888980-1', 'auto');
  ga('send', 'pageview');
</script>\n";
    return $str;
}

#############################################

=head2 html_table

    About   : Depending on the query we will have 2 routes:
              1- tabix with vcf files (chromosome location) /files/wellderly/vcf
              2- RDBMS: SQLite files (Gene and dbSNP id)    /db/wellderly/wellderly_{cg,illumina}.db
    Usage   : None             
    Args    : 

=cut

#############################################

sub html_table {

    my $query            = shift;
    my $allele           = shift;
    my $chr              = '';
    my $warning          = '';
    my $results_cg       = undef;
    my $results_illumina = undef;
    my $results_molau    = undef;
    my $type             = '';
    my $web_services     = 0;

    ( $query, $chr, $type, $warning ) = parse_query( $query, $web_services );

    # Creating an object for the query
    my $db_query = DB->new(
        { chr => $chr, query => $query, type => $type, allele => $allele } );

    # Expanding the object as needed
    # tabix for chr queries
    if ( $type eq 'tabix' ) {
        $db_query->cohort('cg');
        $results_cg = $db_query->get_query_TABIX();
        $db_query->cohort('illumina');
        $results_illumina = $db_query->get_query_TABIX();
        $db_query->cohort('molau');    #
        $results_molau = $db_query->get_query_TABIX();
    }

    # SQLite for the rest
    elsif ( $type eq 'rs' || $type eq 'gene' ) {
        $db_query->cohort('cg');
        $results_cg = $db_query->get_query_SQLite();

        #$db_query->cohort('illumina');
        $db_query->cohort('cg');
        $results_illumina = $db_query->get_query_SQLite();
        $db_query->cohort('molau');
        $results_molau = $db_query->get_query_SQLite();
    }
    elsif ( $type eq 'unknown' ) {
        $results_cg       = undef;
        $results_illumina = undef;
        $results_molau    = undef;
    }
    else {
        $results_cg       = undef;
        $results_illumina = undef;
        $results_molau    = undef;
    }

    my $str = '';

    # Creating Genome Browser results
    #my $genome_browser = genome_browser( $chr, '30000000', '30030000' );

    # Results will come as an array reference
    my $n_variant_cg = defined $results_cg ? scalar @$results_cg : 0;
    my $n_variant_illumina =
      defined $results_illumina ? scalar @$results_illumina : 0;
    my $n_variant_molau = defined $results_molau ? scalar @$results_molau : 0;

    if ( $n_variant_cg || $n_variant_illumina || $n_variant_molau ) { # $results_illumina can come !defined

        my @keys = ();
        push @keys, 'cg'       if $n_variant_cg;
        push @keys, 'illumina' if $n_variant_illumina;
        push @keys, 'molau'    if $n_variant_molau;

        my %vcf_data_loc = (
            chrm => 0, # We add chr-m to be able to grep it uniquevocally if we need to
            pos  => 1,
            rsid     => 2,
            ref      => 3,
            alt      => 4,
            qual     => 5,
            filter   => 6,
            type     => 7,
            gene     => 8,
            isoform  => 9,
            region   => 10,
            location => 11,
            protein  => 12,
            impact   => 13,
            afreq    => 14,
            acount   => 15,
            gfreq    => 16,
            gcount   => 17
        );

        my @cg_vars         = ();
        my @illumina_vars   = ();
        my @molau_vars      = ();
        my @cg_impact       = ();
        my @illumina_impact = ();
        my @molau_impact    = ();
        my @cg_cloud        = ();
        my @illumina_cloud  = ();
        my @molau_cloud     = ();

        my @keys_cg_report =
          qw (chrm pos gene rsid ref alt type isoform region location protein impact afreq acount gfreq gcount filter);
        my @keys_illumina_report = @keys_cg_report;
        my @keys_molau_report    = @keys_cg_report;

        # Hash of arrays
        # Initiially 'platform' was for cg|illumina but with the introduction of molau we switched to cohort
        my %cohort = (
            cg => {
                results => {
                    tabix => $results_cg,
                    html  => '',
                    snp   => 0,
                    other => 0,
                    var   => $n_variant_cg,
                    keys  => [@keys_cg_report],
                },
            },
            illumina => {
                results => {
                    tabix => $results_illumina,
                    html  => '',
                    snp   => 0,
                    other => 0,
                    var   => $n_variant_illumina,
                    keys  => [@keys_illumina_report],
                },
            },
            molau => {
                results => {
                    tabix => $results_molau,
                    html  => '',
                    snp   => 0,
                    other => 0,
                    var   => $n_variant_molau,
                    keys  => [@keys_molau_report],
                },
            },
        );

        # zcat ../../Project_Wellderly/ANNOTATIONS/chr22.annotated.sorted.gz |cut -f25 | grep -v "N/A" | grep "[A-Z]" | sed "s#///#\t#g" |t2n |sort -u
        # In multiallelic entries the regex will get the first match only
        my $regex_impact =
qr/Synonymous|Complex|Frameshift|In_Frame_Deletion|In_Frame_Deletion_One_Altered_Codon|In_Frame_Insertion|In_Frame_Rearrangement|InterCodon_In_Frame_Insertion|Nonsense|Nonsynonymous|Noncoding/
          ;    # order matters

        # Note that visualization may differ from raw data:
        foreach my $key (@keys) {
            foreach my $line ( @{ $cohort{$key}{results}{tabix} } ) {

                my @tmp_fields = split /[\t;]/, $line;    # Same order as VCF
                $line =~ m/($regex_impact)/;
                my $impact = $1 ? lc($1) : '';

                $cohort{cg}{results}{other}++
                  if $tmp_fields[7] =~ /ins|del/i && $key eq 'cg';
                $cohort{illumina}{results}{other}++
                  if $tmp_fields[7] =~ /indel/i && $key eq 'illumina';
                $cohort{molau}{results}{other}++
                  if $tmp_fields[7] =~ /indel/i && $key eq 'molau';

                # Adding filter field
                $tmp_fields[6] = $tmp_fields[6] eq 'PASS' ? 'Yes' : 'No';

                # Cleaning empty fields for visualization purposes
                $tmp_fields[11] =~ s/^[\.,\/]+$/./;
                $tmp_fields[12] =~ s/^[\.,\/]+$/./;
                $tmp_fields[13] =~ s/^[\.,\/]+$/./;

                # Loading a couple of arrays before we add href
                push @cg_vars, "$tmp_fields[7]_$tmp_fields[3]/$tmp_fields[4]"
                  if $key eq 'cg';    # ALT field
                push @illumina_vars,
                  "$tmp_fields[7]_$tmp_fields[3]/$tmp_fields[4]"
                  if $key eq 'illumina';
                push @molau_vars,
                  "$tmp_fields[7]_$tmp_fields[3]/$tmp_fields[4]"
                  if $key eq 'molau';

                # Google charts
                my $tmp_field_4array = $tmp_fields[13];
                $tmp_field_4array =~ m/(\w+)/;    # Reading only 1st occurrence
                $tmp_field_4array = $1 ? $1 : '.';
                if ( $tmp_field_4array ne '.' ) {
                    push @cg_impact,       $tmp_field_4array if $key eq 'cg';
                    push @illumina_impact, $tmp_field_4array
                      if $key eq 'illumina';
                    push @cg_impact, $tmp_field_4array if $key eq 'molau';
                }

                # D3 Cloud
                $tmp_field_4array = $tmp_fields[13];
                $tmp_field_4array =~ m/(\w+)/;    # Reading only 1st occurrence
                $tmp_field_4array = $1 ? $1 : '.';
                if ( $tmp_field_4array ne '.' ) {
                    push @cg_cloud,       $tmp_field_4array if $key eq 'cg';
                    push @illumina_cloud, $tmp_field_4array
                      if $key eq 'illumina';
                    push @molau_cloud, $tmp_field_4array if $key eq 'molau';

                }

                # field 12 is protein
                $tmp_field_4array = $tmp_fields[11];
                $tmp_field_4array =~ m/(\w+)/;    # Reading only 1st occurrence
                $tmp_field_4array = $1 ? $1 : '.';
                if ( $tmp_field_4array ne '.' ) {
                    push @cg_cloud,       $tmp_field_4array if $key eq 'cg';
                    push @illumina_cloud, $tmp_field_4array
                      if $key eq 'illumina';
                    push @molau_cloud, $tmp_field_4array if $key eq 'molau';

                }

                $tmp_field_4array = $tmp_fields[10];
                $tmp_field_4array =~ m/(\w+)/;    # Reading only 1st occurrence
                $tmp_field_4array = $1 ? $1 : '.';
                if ( $tmp_field_4array ne '.' ) {
                    push @cg_cloud,       $tmp_field_4array if $key eq 'cg';
                    push @illumina_cloud, $tmp_field_4array
                      if $key eq 'illumina';
                    push @molau_cloud, $tmp_field_4array if $key eq 'molau';
                }

                $tmp_field_4array = $tmp_fields[4];    # Alt base
                $tmp_field_4array =~ m/(\w+)/;    # Reading only 1st occurrence
                $tmp_field_4array = $1 ? $1 : '.';
                if ( $tmp_field_4array ne '.' ) {
                    push @cg_cloud,       $tmp_field_4array if $key eq 'cg';
                    push @illumina_cloud, $tmp_field_4array
                      if $key eq 'illumina';
                    push @molau_cloud, $tmp_field_4array if $key eq 'molau';
                }

                # Adding <br /> to ieach allele for impact
                $tmp_fields[9]  =~ s#,#<br\/>#g;
                $tmp_fields[10] =~ s#,#<br\/>#g;
                $tmp_fields[11] =~ s#,#<br\/>#g;
                $tmp_fields[12] =~ s#,#<br\/>#g;
                $tmp_fields[13] =~ s#,#<br\/>#g;

                # dbSNP ID can be multiple
                my @ids = split /,/, $tmp_fields[2];

                my $tmp_str_rs = '';
                for my $dbsnp (@ids) {
                    if ( $dbsnp ne '.' ) {
                        my $tmp_dest =
"http://www.ncbi.nlm.nih.gov/SNP/snp_ref.cgi?rs=$dbsnp";
                        $dbsnp =~
s#$dbsnp#<a target=\\"_blank\\" href=\\"$tmp_dest\\">$dbsnp,<br /></a>#
                          if $dbsnp ne $ids[-1];
                        $dbsnp =~
s#$dbsnp#<a target=\\"_blank\\" href=\\"$tmp_dest\\">$dbsnp</a>#
                          if $dbsnp eq $ids[-1];
                    }
                    $tmp_str_rs .= $dbsnp;
                }
                $tmp_fields[2] =
                    $tmp_str_rs
                  ? $tmp_str_rs
                  : '.';    # To fix empty column from rs2;

                # Alleles can be multiple
                if ($gnomAD) {
                    my @exacs = split /,/, $tmp_fields[4];

                    my $tmp_str_exac = '';
                    for my $exac (@exacs) {
                        my $tmp_dest =
"http://gnomad.broadinstitute.org/variant/$tmp_fields[0]-$tmp_fields[1]-$tmp_fields[3]-$exac";
                        $exac =~
s#$exac#<a target=\\"_blank\\" href=\\"$tmp_dest\\">$exac,<br /></a>#
                          if $exac ne $exacs[-1];
                        $exac =~
s#$exac#<a target=\\"_blank\\" href=\\"$tmp_dest\\">$exac</a>#
                          if $exac eq $exacs[-1];
                        $tmp_str_exac .= $exac;
                    }
                    $tmp_fields[4] = $tmp_str_exac;
                }

                # Adding more Hrefs
                $tmp_fields[1] =~
s#$tmp_fields[1]#<a target=\\"_blank\\" href=\\"http://www.rcsb.org/pdb/chromosome.do?v=hg37&chromosome=chr$tmp_fields[0]&pos=$tmp_fields[1]\\">$tmp_fields[1]</a>#

                  if $PDB;
                $tmp_fields[8] =~
s#$tmp_fields[8]#<a target=\\"_blank\\" href=\\"http://www.genecards.org/cgi-bin/carddisp.pl?gene=$tmp_fields[8]\\">$tmp_fields[8]</a>#
                  if $tmp_fields[8] ne '.';

                # Loading modified_JSON
                $cohort{$key}{results}{html} .= '[';
                foreach my $tmp_field ( @{ $cohort{$key}{results}{keys} } ) {
                    $cohort{$key}{results}{html} .=
                      "\"$tmp_fields[$vcf_data_loc{$tmp_field} ]\",";
                }
                chop $cohort{$key}{results}{html};    # delete last ,
                $cohort{$key}{results}{html} .= '],'; # Ad-hoc

            }
            chop $cohort{$key}{results}{html};        # delete last ,
        }

        # Printing modified JSON for dataTables now (outside the loop )
        # in order to get both mod_json files. Otherwise js will complain about not having json file
        print_mod_JSON( $cohort{cg}{results}{html},       'cg' );
        print_mod_JSON( $cohort{illumina}{results}{html}, 'illumina' );
        print_mod_JSON( $cohort{molau}{results}{html},    'molau' );

        $cohort{cg}{results}{snp} =
          $cohort{cg}{results}{var} - $cohort{cg}{results}{other};
        $cohort{illumina}{results}{snp} =
          $cohort{illumina}{results}{var} - $cohort{illumina}{results}{other};
        $cohort{molau}{results}{snp} =
          $cohort{molau}{results}{var} - $cohort{molau}{results}{other};

        # Counting Variants in Genes
        my $tmp_arr1 = count_var_type( \@cg_vars );
        my $tmp_arr2 = count_var_type( \@illumina_vars );
        my $tmp_arr3 = count_var_type( \@molau_vars );

        my $n_cg_impact       = scalar @cg_impact;
        my $n_illumina_impact = scalar @illumina_impact;
        my $n_molau_impact    = scalar @molau_impact;

        my $cloud_words_cg       = count_var_impact( 1, \@cg_cloud );
        my $cloud_words_illumina = count_var_impact( 1, \@illumina_cloud );
        my $cloud_words_molau    = count_var_impact( 1, \@molau_cloud );

        # We create downloadable files
        my $file_summary = print_summary(
            {
                query          => $query,
                n_var_cg       => $cohort{cg}{results}{var},
                n_var_illumina => $cohort{illumina}{results}{var},
                n_var_molau    => $cohort{molau}{results}{var},

                n_SNP_cg       => $cohort{cg}{results}{snp},
                n_Other_cg     => $cohort{cg}{results}{other},
                n_SNP_illumina => $cohort{illumina}{results}{snp},

                n_Other_illumina => $cohort{illumina}{results}{other},
                n_SNP_molau      => $cohort{molau}{results}{snp},
                n_Other_molau    => $cohort{molau}{results}{other}
            }
        );
        my (
            $file_cg_VCF,        $file_cg_JSON,   $file_illumina_VCF,
            $file_illumina_JSON, $file_molau_VCF, $file_molau_JSON
        ) = ('#') x 6;
        if ($n_variant_cg) {
            $file_cg_VCF  = print_VCF( $results_cg, 'cg', 1 );
            $file_cg_JSON = print_JSON( $results_cg, 'cg', 1 );
        }
        if ($n_variant_illumina) {
            $file_illumina_VCF = print_VCF( $results_illumina, 'illumina', 1 );
            $file_illumina_JSON =
              print_JSON( $results_illumina, 'illumina', 1 );
        }
        if ($n_variant_molau) {
            $file_molau_VCF  = print_VCF( $results_molau, 'molau', 1 );
            $file_molau_JSON = print_JSON( $results_molau, 'molau', 1 );
        }

        # Here it comes the actual HTML
        my $google_charts   = google_charts( $tmp_arr1, $tmp_arr2, $tmp_arr3 );
        my $d3_tag_cloud_cg = d3_tag_cloud( 'cg', $cloud_words_cg );
        my $d3_tag_cloud_illumina =
          d3_tag_cloud( 'illumina', $cloud_words_illumina );
        my $d3_tag_cloud_molau = d3_tag_cloud( 'molau', $cloud_words_molau );
        $str = << "EOF";
        $google_charts

  </head>

  <body class="dt-example">


      <div class="container">


      <div class="pull-right collapse navbar-collapse">
        <ul class="nav navbar-nav">
          <li><a class="btn btn-default pull-right" href="$file_summary"><i class="icon icon-download"></i> Summary</a></li>
          <li class="dropdown"><a class="dropdown-toggle btn btn-default" data-toggle="dropdown" href="#"> <i class="icon icon-download"></i> VCF <span class="caret"></span></a>
            <ul class="dropdown-menu">
              <li><a href="$file_cg_VCF">Wellderly - Complete Genomics</a></li>
              <li><a href="$file_illumina_VCF">Wellderly - Illumina</a></li>
              <li><a href="$file_molau_VCF">Molecular Autopsy</a></li>
            </ul>
          </li>
          <li class="dropdown"><a class="dropdown-toggle btn btn-default" data-toggle="dropdown" href="#"> <i class="icon icon-download"></i> JSON <span class="caret"></span></a>
            <ul class="dropdown-menu">
              <li><a href="$file_cg_JSON">Wellderly - Complete Genomics</a></li>
              <li><a href="$file_illumina_JSON">Wellderly - Illumina</a></li>
              <li><a href="$file_molau_JSON">Molecular Autopsy</a></li>
            </ul>
          </li>
        </ul>
      </div>

     <h3>Results &#9658 $query</h3>

      <div>

       <ul class="nav nav-tabs">
       <li class="active"><a href="#tab-summary" data-toggle="tab">Summary</a></li>
EOF

        $str .=
"<li><a href=\"#tab-cg-report\" data-toggle=\"tab\">Wellderly - Complete Genomics (WGS)</a></li>"
          if $n_variant_cg > 0;
        $str .=
"<li><a href=\"#tab-illumina-report\" data-toggle=\"tab\">Wellderly - Illumina (WGS)</a></li>"
          if $n_variant_illumina > 0;
        $str .=
"<li><a href=\"#tab-molau-report\" data-toggle=\"tab\">Molecular Autopsy (WES)</a></li>"
          if $n_variant_molau > 0;

        # <li class=""><a href="#tab-var-exp" data-toggle="tab">Variant Explorer</a></li>
        # <li class=""><a href="#tab-gen-browser" data-toggle="tab">Browser</a></li>
        $str .= << "EOF";

       <li><a id="new-search-from-results-btn" class="active btn btn-info btn-lg nohover" role="button">New Search <i class="icon icon-search"></i></a></li>
       </ul>

      <div id="myTabContent" class="tab-content">
      <div class="tab-pane fade in active" id="tab-summary">
               $warning
               <strong>Wellderly - Complete Genomics (WGS):</strong> $cohort{cg}{results}{var} variants <strong>SNP:</strong> $cohort{cg}{results}{snp}  <strong>Other:</strong> $cohort{cg}{results}{other}<br />
               <strong>Wellderly - Illumina (WGS):</strong> $cohort{illumina}{results}{var} variants <strong>SNP:</strong> $cohort{illumina}{results}{snp}  <strong>Other:</strong> $cohort{illumina}{results}{other}<br />
               <strong>Molecular Autopsy (WES):</strong> $cohort{molau}{results}{var} variants <strong>SNP:</strong> $cohort{molau}{results}{snp}  <strong>Other:</strong> $cohort{molau}{results}{other}</p>

EOF

        my $tmp_style =
          ' class="col-md-2" style="width: 350px; height: 250px;" ';
        $str .= '<div id="donutchart-cg"' . $tmp_style . '></div>' . "\n"
          if $n_variant_cg;
        $str .= '<div id="donutchart-illumina" ' . $tmp_style . '></div>' . "\n"
          if $n_variant_illumina;
        $str .= '<div id="donutchart-molau" ' . $tmp_style . '></div>' . "\n"
          if $n_variant_molau;

        #$tmp_style = ' class="col-md-4" ';
        $str .= '<div id="cloud-cg" ' . $tmp_style . '></div>' . "\n"
          if $n_illumina_impact; # Displaying only if Wellderly-Illumina has information
        $str .= '<div id="cloud-illumina" ' . $tmp_style . '></div>' . "\n"
          if $n_illumina_impact;
        $str .= '<div id="cloud-molau" ' . $tmp_style . '></div>' . "\n"
          if $n_illumina_impact;

        $str .=
          $d3_tag_cloud_cg . $d3_tag_cloud_illumina . $d3_tag_cloud_molau; # NEEDS TO BE AFTER the DECLARATION OF DIV

        # //datatables.net/forums/discussion/32119/version-1-10-10-scrollx-bug
        $str .= << "EOF";
 
      </div>

      <div class="tab-pane fade in" id="tab-cg-report">
      $warning
      <p><strong> Content:</strong> In this tab we are showing Wellderly - Complete Genomics variants</p>
      <!-- TABLE -->
      <table id="table-cg-report" class="display table table-hover table-condensed break-word">
      <thead> 
      <th>Chr</th>
      <th>Pos</th>
      <th>Gene</th>
      <th>RSID</th>
      <th>Ref</th>
      <th>Alt</th>
      <th>Type</th>
      <th>Isoform</th>
      <th>Region</th>
      <th>Location</th>
      <th>Protein</th>
      <th>Impact</th>
      <th>Allele Freq</th>
      <th>Allele Count</th>
      <th>Genotype Freq</th>
      <th>Genotype Count</th>
      <th>Filters Passed</th>
      </thead>
      </table>
      </div>


      <div class="tab-pane fade in" id="tab-illumina-report">
      $warning
      <p><strong> Content:</strong> In this tab we are showing Wellderly - Illumina variants</p>

      <!-- TABLE -->
      <table id="table-illumina-report" class="display table table-hover table-condensed break-word">
      <thead> 
      <th>Chr</th>
      <th>Pos</th>
      <th>Gene</th>
      <th>RSID</th>
      <th>Ref</th>
      <th>Alt</th>
      <th>Type</th>
      <th>Isoform</th>
      <th>Region</th>
      <th>Location</th>
      <th>Protein</th>
      <th>Impact</th>
      <th>Allele Freq</th>
      <th>Allele Count</th>
      <th>Genotype Freq</th>
      <th>Genotype Count</th>
      <th>Filters Passed</th>
      </thead>
      </table>
      </div>

      <div class="tab-pane fade in" id="tab-molau-report">
      $warning
      <p><strong> Content:</strong> In this tab we are showing Molecular Autopsy variants</p>

      <!-- TABLE -->
      <table id="table-molau-report" class="display table table-hover table-condensed break-word">
      <thead> 
      <th>Chr</th>
      <th>Pos</th>
      <th>Gene</th>
      <th>RSID</th>
      <th>Ref</th>
      <th>Alt</th>
      <th>Type</th>
      <th>Isoform</th>
      <th>Region</th>
      <th>Location</th>
      <th>Protein</th>
      <th>Impact</th>
      <th>Allele Freq</th>
      <th>Allele Count</th>
      <th>Genotype Freq</th>
      <th>Genotype Count</th>
      <th>Filters Passed</th>
      </thead>
      </table>
      </div>

</div>
EOF

        #      <div class="tab-pane fade in" id="tab-gen-browser">
        #      <div class="embed-responsive embed-responsive-16by9 md-col-9 active"><iframe src="$url_genome_browser" style='border:0;'></iframe></div>
        #      </div>
        #
        #
        #</div>
        #EOF
    }
    else {
        $str =
'<div class="jumbotron"><h3>No results found :-( </h3><p><a id="new-search-btn" class="btn btn-info btn-lg" role="button">New Search <i class="icon icon-search"></i></a></p></div>';

    }
    return $str;

}

#############################################

=head2 print_summary

    About   : 
    Usage   : None             
    Args    : 

=cut

#############################################

sub print_summary {

    my $arg = shift;

    # Loading a variable to be printed later
    my $str = '';
    $str .= "Scripps Research Translational Institute\n";
    $str .= "Variant Browser Version $version\n";
    $str .= "***************************************\n";
    $str .= "\n";
    $str .= "Job id: $job_id\n";
    $str .= "Query: $arg->{query}\n";
    $str .= "\n";
    $str .=
"Wellderly - Complete_Genomics: $arg->{n_var_cg}, SNP: $arg->{n_SNP_cg}, Other: $arg->{n_Other_cg}
Wellderly - Illumina: $arg->{n_var_illumina}, SNP: $arg->{n_SNP_illumina}, Other: $arg->{n_Other_illumina}
Molecular Autopsy: $arg->{n_var_molau}, SNP: $arg->{n_SNP_molau}, Other: $arg->{n_Other_molau}\n";

    my $dir  = $job_dir;
    my $file = $job_dir . '/' . 'stsi_' . $job_id . '.csv';

    open( my $fh, ">", $file );
    print $fh $str;
    close $fh;
    return $file;
}

#############################################

=head2 print_VCF

    About   :
    Usage   : None             
    Args    : 

=cut

#############################################

sub print_VCF {

    my $string = shift;    # Array reference
    my $type   = shift;
    my $flag   = shift;
    my $file   = '';

    if ($flag) {
        $file = $job_dir . '/' . 'stsi_' . $job_id . '.' . $type . '.vcf.gz';
        my $fh = IO::Compress::Gzip->new($file);
        print $fh add_header_VCF();

        # We avoid splitting here to make it faster
        print $fh map { $_ . "\n" } @$string;    # Add \n to the ref_array
        close $fh;

    }
    else {
        if ($string) {
            $file = add_header_VCF();
            $file .= join( "\n", @$string ) . "\n";
        }
        else {
            $file = "No results\n";
        }
    }
    return $file;
}

#############################################

=head2 print_JSON

    About   : JSON serialization
    Usage   : None             
    Args    : 

=cut

#############################################

sub print_JSON {

    my $string = shift;    # Array reference
    my $type   = shift;
    my $flag   = shift;
    my $file   = '';

    if ($flag) {
        $file = $job_dir . '/' . 'stsi_' . $job_id . '.' . $type . '.json.gz';
        my $fh = IO::Compress::Gzip->new($file);

        my $str = JSON::XS->new->pretty(1)->encode($string);
        $str =~ s/\\t/,/g;
        print $fh $str;
        close $fh;
    }
    else {
        if ($string) {
            $file = JSON::XS->new->pretty(1)->encode($string);
            $file =~ s/\\t/,/g;
        }
        else {
            $file = "No results\n";
        }
    }
    return $file;
}

#############################################

=head2 print_mod_JSON

    About   : JSON file for dataTables
    Usage   : None             
    Args    : 

=cut

#############################################

sub print_mod_JSON {

    my $string = shift;                                # Array reference
    my $cohort = shift;
    my $file   = $job_dir . '/' . $cohort . '.json';
    open( my $fh, ">", $file );
    print $fh '{"data":[' . $string . ']}';
    close $fh;
}

#############################################

=head2 add_header_VCF

    About   : 
    Usage   : None             
    Args    : 

=cut

#############################################

sub add_header_VCF {

    my $header = "##fileformat=VCFv4.2
##SRTI-VariantBrowserVersion=$version
##INFO=<ID=INFO,Type=String,Description=\"Fields relative to SRTI's Variant Browser=VariationType;Gene;Isoform;Region;Location;Protein;Impact;AlleleFrequencies;AlleleCounts;GenotypeFrequencies;GenotypeCounts\">
#CHROM	POS	ID	REF	ALT	QUAL	FILTER	INFO
";
    return $header;
}

#############################################

=head2 count_var_type

    About   : 
    Usage   : None             
    Args    : 

=cut

#############################################

sub count_var_type {

    my $types = shift;
    my $n     = scalar @$types;
    my $cut =
        $n > 1000 ? 50
      : $n > 100  ? 5
      :             1;
    my %counts;
    $counts{$_}++ for @$types;
    my $tmp_arr = '';
    foreach my $occurrence (
        sort { $counts{$b} <=> $counts{$a} }
        keys %counts
      )
    {
        $tmp_arr .= "[ '$occurrence', $counts{$occurrence} ],\n";
        last if $counts{$occurrence} < $cut;
    }
    return $tmp_arr;
}

#############################################

=head2 count_var_impact

    About   : 
    Usage   : None             
    Args    : 

=cut

#############################################

sub count_var_impact {

    my $json   = shift;
    my $impact = shift;
    my %counts;
    $counts{$_}++ for @$impact;
    my $tmp_arr = '';

    foreach my $occurrence (
        sort { $counts{$b} <=> $counts{$a} }
        keys %counts
      )
    {
        next if $occurrence eq '.';

        # json is used in d3 cloud
        if ($json) {

            my $tmp_value = 20 + int sqrt $counts{$occurrence};
            $tmp_value = 100 if $tmp_value > 100;
            $tmp_arr .= "{word:\"$occurrence\", weight:$tmp_value},";
        }

        # Google charts
        else {
            $tmp_arr .= "[ '$occurrence', $counts{$occurrence} ],\n";
        }
        last if $counts{$occurrence} < 10;
    }
    chop $tmp_arr;    # delete last ,
    return $tmp_arr;
}

#############################################

=head2 jQuery_autocomplete

    About   : 
    Usage   : None             
    Args    : 

=cut

#############################################

sub _jQuery_autocomplete {

    my $str = '';
    $str = << "EOF";

<link rel="stylesheet" href="//code.jquery.com/ui/1.11.4/themes/smoothness/jquery-ui.css">
<script src="//code.jquery.com/ui/1.11.4/jquery-ui.js"></script>
<script>
  \$(function() {
    var availableTags;
    \$.get("DB/genes.txt", function(data) {
        availableTags = data.split('\\n');
         \$( "#query" ).autocomplete({source:availableTags})
     });
  });
</script>
EOF
    return $str;
}

#############################################

=head2 dataTables_js

    About   : 
    Usage   : None             
    Args    : 

=cut

#############################################

sub dataTables_js {

    my $str = '';
    $str = << "EOF";

<script type="text/javascript" language="javascript" class="init">

\$(document).ready(function() {
    \$('#table-cg-report').dataTable( {
       "ajax": "$job_dir/cg.json",
       "bDeferRender": true,
       "language": {
         "sSearch": '<span class="glyphicon glyphicon-search" aria-hidden="true"></span>',
         "lengthMenu": "Show _MENU_ variants",
         "sInfo": "Showing _START_ to _END_ of _TOTAL_ variants",
          "sInfoFiltered": " (filtered from _MAX_ variants)"
       },
       order: [ 1, "asc" ],
       search: {
          "regex": true
         },
       dom: 'CRT<"clear">lfrtip',
       columnDefs: [
            { visible: false, targets: [ 7, 9, 10, 11, 13, 15, 16 ] }
        ],
       colVis: {
            showAll: "Show all",
            showNone: "Show none"
        },
          tableTools: {
            aButtons: [ { "sExtends": "print" , "sButtonText": '<span class="glyphicon glyphicon-print" aria-hidden="true"></span>' } ]
        } 
    } );
} );
\$(document).ready(function() {
    \$('#table-illumina-report').dataTable( {
       "ajax": "$job_dir/illumina.json",
       "bDeferRender": true,
       "language": {
         "sSearch": '<span class="glyphicon glyphicon-search" aria-hidden="true"></span>',
         "lengthMenu": "Show _MENU_ variants",
         "sInfo": "Showing _START_ to _END_ of _TOTAL_ variants",
          "sInfoFiltered": " (filtered from _MAX_ variants)"
        },
       order: [ 1, "asc" ],
       search: {
          "regex": true
         },
       dom: 'CRT<"clear">lfrtip',
       columnDefs: [
            { visible: false, targets: [ 7, 9, 10, 11, 13, 15, 16 ] }
        ],
       colVis: {
            showAll: "Show all",
            showNone: "Show none"
        },
          tableTools: {
            aButtons: [ { "sExtends": "print" , "sButtonText": '<span class="glyphicon glyphicon-print" aria-hidden="true"></span>' } ]
        } 
    } );
} );
\$(document).ready(function() {
    \$('#table-molau-report').dataTable( {
       "ajax": "$job_dir/molau.json",
       "bDeferRender": true,
       "language": {
         "sSearch": '<span class="glyphicon glyphicon-search" aria-hidden="true"></span>',
         "lengthMenu": "Show _MENU_ variants",
         "sInfo": "Showing _START_ to _END_ of _TOTAL_ variants",
          "sInfoFiltered": " (filtered from _MAX_ variants)"
        },
       order: [ 1, "asc" ],
       search: {
          "regex": true
         },
       dom: 'CRT<"clear">lfrtip',
       columnDefs: [
            { visible: false, targets: [ 7, 9, 10, 11, 13, 15, 16 ] }
        ],
       colVis: {
            showAll: "Show all",
            showNone: "Show none"
        },
          tableTools: {
            aButtons: [ { "sExtends": "print" , "sButtonText": '<span class="glyphicon glyphicon-print" aria-hidden="true"></span>' } ]
        } 
    } );
} );

</script>
EOF
    return $str;
}

#############################################

=head2 google_charts

    About   : 
    Usage   : None             
    Args    : 

=cut

#############################################

sub google_charts {

    my $tmp_arr1 = shift;
    my $tmp_arr2 = shift;
    my $tmp_arr3 = shift;

    my $str = '';

    $str .= << "EOF";

    <script type="text/javascript" src="https://www.google.com/jsapi"></script>

    <script type="text/javascript">
      google.load("visualization", "1", {packages:["corechart"]});
      google.setOnLoadCallback(drawChart);
      function drawChart() {
        var data = google.visualization.arrayToDataTable([
          ['Gene', 'Number of variants'],
          $tmp_arr1
        ]);

        var options = {
          title: 'Top variants (Wellderly - CG)',
          pieHole: 0.4,
        };

        var chart = new google.visualization.PieChart(document.getElementById('donutchart-cg'));
        chart.draw(data, options);
      }
    </script>
    
    <script type="text/javascript">
      google.load("visualization", "1", {packages:["corechart"]});
      google.setOnLoadCallback(drawChart);
      function drawChart() {
        var data = google.visualization.arrayToDataTable([
          ['Gene', 'Number of variants'],
          $tmp_arr2
        ]);

        var options = {
          title: 'Top variants (Wellderly - Illumina)',
          pieHole: 0.4,
        };

        var chart = new google.visualization.PieChart(document.getElementById('donutchart-illumina'));
        chart.draw(data, options);
      }
    </script>
   <script type="text/javascript">
      google.load("visualization", "1", {packages:["corechart"]});
      google.setOnLoadCallback(drawChart);
      function drawChart() {
        var data = google.visualization.arrayToDataTable([
          ['Gene', 'Number of variants'],
          $tmp_arr3
        ]);

        var options = {
          title: 'Top variants (Molecular Autopsy)',
          pieHole: 0.4,
        };

        var chart = new google.visualization.PieChart(document.getElementById('donutchart-molau'));
        chart.draw(data, options);
      }
    </script>


EOF
    return $str;

}

#############################################

=head2 print_log

    About   : 
    Usage   : None             
    Args    : 

=cut

#############################################

sub print_log {

    my $argument = shift;
    my $html     = shift;                 # 0 or 1
    my $log      = "log/log.txt";
    my $ip       = $ENV{'REMOTE_ADDR'};

    # GeoIP is deprecated
    # Morevover, genomics.scripps.edu acts as a proxy and thus we only get its location :-(
    #my $geoip    = GeoIP($ip);
    my $geoip = 'US,California,La Jolla';

    # Adding the info to the logfile (blocking overwritting)
    open( my $fh, ">>", $log );
    lock($fh);
    print $fh localtime()
      . " :: $job_id :: $html :: $ip :: $geoip :: $argument\n";
    unlock($fh);
    close $fh;
}

sub lock {

    my ($fh) = @_;
    flock( $fh, LOCK_EX );

    # and, in case someone appended while we were waiting...
    seek( $fh, 0, SEEK_END );
}

sub unlock {

    my ($fh) = @_;
    flock( $fh, LOCK_UN );
}

#sub GeoIP {
#   my $ip = shift;
#   my $gi = Geo::IP->open( "/usr/share/GeoIP/GeoIP.dat", GEOIP_STANDARD );
#   my $record = $gi->record_by_addr($ip);
#   my $str    = join( ',', $record->country, $record->region, $record->city);
#  return $str;
#}

############################################

=head2 submit_cmd
    
    About   : Subroutine that sends systems calls
    Usage   : None             
    Args    : 
    
=cut

#############################################

sub submit_cmd {

    my $cmd = shift;
    system("$cmd") == 0 or die("failed to execute: $!\n");
}

#############################################

=head2 web_services

    About   : 
    Usage   : None             
    Args    : 

=cut

#############################################

sub web_services {

    my $self       = shift;
    my $query        = $self->{query};
    my $cohort       = $self->{cohort};
    my $format       = $self->{format};
    my $chr          = '';
    my $type         = '';
    my $web_services = 1;
    ( $query, $chr, $type, undef ) = parse_query( $query, $web_services );

    # Printing the log
    print_log( $query, 0 );

    # Creating an object for the query
    my $db_query = DB->new(
        { chr => $chr, query => $query, type => $type, allele => undef } );
    $db_query->cohort($cohort);

    my $results = '';

    # TABIX for chr queries
    if ( $type eq 'tabix' ) {
        $results = $db_query->get_query_TABIX();
    }

    # SQLite for others
    elsif ( $type eq 'rs' || $type eq 'gene' ) {
        $results = $db_query->get_query_SQLite();
    }
    else {
        $results = '';
    }

    my $file_out = '';
    $file_out = print_VCF( $results, $cohort, 0 )  if $format eq 'vcf';
    $file_out = print_JSON( $results, $cohort, 0 ) if $format eq 'json';
    return $file_out;
}

#############################################

=head2 parse_query

    About   : 
    Usage   : None             
    Args    : 

=cut

#############################################

sub parse_query {

    my $query = shift;
    $query =~ s/\s+//g;
    $query =~ s/,//g;
    $query =~ s/^chr?m?//i
      if $query =~ /\:/; # r and m are optional. Note that query must contain ':' otherwise gene CHRNA5 will become NA5 :-)
    my $web_services = shift;
    my $type         = '';
    my $chr          = '';
    my $max_size     = 500000;
    my $max_size_str = $max_size / 1000 . ' kb';

    my $warning = '';
    if ( $query =~ /(.+)\:(\d+)-(\d+)/ ) {
        $type = 'tabix';
        $chr  = uc($1);
        my $init = $2;
        my $end  = $3;
        my $size = $end - $init;

        # We limit the region if search came from HTML
        if ( !$web_services && $size > $max_size ) {
            $end = $init + $max_size;
            $warning =
"</p><span class=\"label label-danger\">Warning</span> For large regions, we recomend downloading our <a href=\"http://wellderlyweb.scripps.edu/files/wellderly/vcf\">raw</a> data or using our <a href=\"page-help.html\">web services</a>. Showing only $max_size_str.</p>";
            $query = $chr . ':' . $init . '-' . $end;
        }

    }
    elsif ( $query =~ /(.+)\:(\d+)/ ) {
        $type = 'tabix';
        $chr  = uc($1);
        my $init = $2;
        my $end  = $2;
        $query = $chr . ':' . $init . '-' . $end;
    }
    elsif ( $query =~ /^rs/i ) {
        $type  = 'rs';
        $query = lc($query);
    }
    elsif ( $query =~ /[\w\d]{3,8}/i ) {
        $type  = 'gene';
        $query = uc($query);
    }
    else {
        $type = 'unknown';
    }

    return ( $query, $chr, $type, $warning );
}

#############################################

=head2 beacon_form

    About   : 
    Usage   : None             
    Args    : 

=cut

#############################################

sub beacon_form {

    my $str = << "EOF";
        <div role="main" class="main">
	<section class="page-top">
		<div class="container">
			<div class="row">
				<div class="col-md-12">
					<h2><strong>Beacon</strong> search</h2>
				</div>
			</div>
		</div>
	</section>

	<div class="container">
		<div class="row">
			<div class="col-md-12">
				<p class="lead">
                                                       Global Alliance for Genomics and Health
				</p>
			</div>
		</div>
	</div>
        <div class="container">
            <div class="row row-centered">
                <div id="banner"></div>
                <div class="col-xs-6 col-centered wide-container">
                    <form method="post" class="form-horizontal" action="ga4gh">
                        <div class="form-group">
                            <label for="beacon" class="control-label col-xs-3">Beacon</label>
                            <div class="col-xs-9" id="beaconlist">
                               <select class="form-control" name="beacon" id="beacon">
                                    <option value="stsi">Scripps Genomic Medicine</option>
                                </select>
                            
                            </div>
                        </div>
                        <div class="form-group">
                            <label for="ref" class="control-label col-xs-3">Genome</label>
                            <div class="col-xs-9">
                                <select class="form-control" name="ref" id="ref">
                                    <option value="hg19">GRCh37/hg19</option>
                                </select>
                            </div>
                        </div>
                        <div class="form-group">
                            <label for="chrom" class="control-label col-xs-3">Chromosome</label>
                            <div class="col-xs-9">
                                <select class="form-control" name="chr" id="chr">
                                    <option value="1">1</option>
                                    <option value="2">2</option>
                                    <option value="3">3</option>
                                    <option value="4">4</option>
                                    <option value="5">5</option>
                                    <option value="6">6</option>
                                    <option value="7">7</option>
                                    <option value="8">8</option>
                                    <option value="9">9</option>
                                    <option value="10">10</option>
                                    <option value="11">11</option>
                                    <option value="12">12</option>
                                    <option value="13">13</option>
                                    <option value="14">14</option>
                                    <option value="15">15</option>
                                    <option value="16">16</option>
                                    <option value="17">17</option>
                                    <option value="18">18</option>
                                    <option value="19">19</option>
                                    <option value="20">20</option>
                                    <option value="21">21</option>
                                    <option value="22">22</option>
                                    <option value="X">X</option>
                                    <option value="Y">Y</option>
                                </select>
                            </div>
                        </div>
                        <div class="form-group">
                            <label for="pos" class="control-label col-xs-3">Position</label>
                            <div class="col-xs-9">
                                <input type="text" class="form-control" name="pos" id="pos" placeholder="">
                                <small style="color:rgb(130,130,130)">0-based coordinate</small>
                            </div>
                        </div>
                        <div class="form-group">
                            <label for="alt" class="control-label col-xs-3">Allele</label>
                            <div class="col-xs-9">
                                <input type="text" class="form-control" name="alt" id="alt" placeholder="">
                            </div>
                        </div>


                        <div class="form-group">
                            <div class="col-xs-offset-3 col-xs-9 row-centered">
                                <button type="submit" class="btn btn-primary full">
                                    Query
                                </button>
                            </div>
                        </div>
                    </form>
                </div>
            </div>
        </div>
EOF

}

#############################################

=head2 genome_browser

    About   : 
    Usage   : None             
    Args    : 

=cut

#############################################

sub genome_browser {

    my $chr   = shift;
    my $start = shift;
    my $end   = shift;
    my $str   = << "EOF";

<script language="javascript" src="http://www.biodalliance.org/release-0.11/dalliance-compiled.js"></script>
<script language="javascript">
  new Browser({
    chr:          '$chr',
    viewStart:    $start 
    viewEnd:      $end
    cookieKey:    'human',

    coordSystem: {
      speciesName: 'Human',
      taxon: 9606,
      auth: 'NCBI',
      version: '36',
      ucscName: 'hg18'
    },

    sources:     [{name:                 'Genome',      
                   uri:                  'http://www.derkholm.net:8080/das/hg18comp/',        
                   tier_type:            'sequence',
                   provides_entrypoints: true},
                  {name:                 'Genes',     
                   desc:                 'Gene structures from Ensembl 54',
                   uri:                  'http://www.derkholm.net:8080/das/hsa_54_36p/',      
                   collapseSuperGroups:  true,
                   provides_karyotype:   true,
                   provides_search:      true},
                  {name:                 'Repeats',     
                   uri:                  'http://www.derkholm.net:8080/das/hsa_54_36p/',      
                   stylesheet_uri:       'http://www.derkholm.net/dalliance-test/stylesheets/ens-repeats.xml'},
                  {name:                 'MeDIP raw',
                   uri:                  'http://www.derkholm.net:8080/das/medipseq_reads'},
                  {name:                 'MeDIP-seq',
                   uri:                  'http://www.ebi.ac.uk/das-srv/genomicdas/das/batman_seq_SP/'}]
  });
</script>

EOF
    return $str;

}

#############################################

=head2 d3_tag_cloud

    About   : 
    Usage   : None             
    Args    : 

=cut

#############################################

sub d3_tag_cloud {

    my $cohort = shift;
    my $words  = shift;

    # Assigning weight from parsing the string
    my @weights            = $words =~ m/weight:(\d+)}/g;
    my $cohort_word_weight = 1 + max @weights;
    my $tmp_word           = ",{word:\"$cohort\", weight:$cohort_word_weight}";
    $words = $words . $tmp_word;

    my $str = << "EOF";
 <script>
 var fill = d3.scale.category20();
 var data = [$words];

  var	margin = {top: 0, right: 0, bottom: 0, left: 0},
	width = 385 - margin.left - margin.right,
	height = 300 - margin.top - margin.bottom;

  d3.layout.cloud()
      .words(data.map(function(d) {
              return {text: d.word, size: d.weight};
       }))
      .rotate(function() { return ~~(Math.random() * 2) * 90; })
      .font("Impact")
      .fontSize(function(d) { return d.size; })
      .on("end", draw)
      .start();

    function draw(words) {
    d3.select("#cloud-$cohort").append("svg")
       .attr("width", width + margin.left + margin.right)
	.attr("height", height + margin.top + margin.bottom)
      .append("g")
        .attr("transform", "translate(150,150)")
      .selectAll("text")
        .data(words)
      .enter().append("text")
        .style("font-size", function(d) { return d.size + "px"; })
        .style("font-family", "Impact")
        .style("fill", function(d, i) { return fill(i); })
        .attr("text-anchor", "middle")
        .attr("transform", function(d) {
          return "translate(" + [d.x, d.y] + ")rotate(" + d.rotate + ")";
        })
        .text(function(d) { return d.text; });
  }
 </script>
EOF

}

1;
