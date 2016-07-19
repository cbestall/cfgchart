/**
*
* @file  gCharts.cfc
* @author  Chris Bestall
* @description
*
*/

component output="false" displayname="Google Chart API"  {

	VARIABLES.gChartURL = "http://chart.apis.google.com/chart?";
	VARIABLES.chartColors = ["2C9CFF", "5FCFFF", "96DFFF", "00127E", "B2F0FF"];

	public function init(){

		VARIABLES.attributes = {
			"chm"  = "",	/* Marker and Format */
			"cht"  = "bvg", 							/* Chart Type */
			"chs"  = "800x200", 						/* Chart Size ( width x height ) */
			"chtt" = "Chart Title", 					/* Chart Title */
			"chts" = "000000,20", 						/* Chart Title Size */
			"chxt" = "x,y", 							/* Show Axis Labels */
			"chds" = "a", 								/* Auto Scale */
			"chco" = "", 								/* Colors */
			"chxl" = "", 								/* X,Y Labels */
			"chd"  = "" 								/* Series Data */
		};
		VARIABLES.chartSeriesIndex = 1;

		return this;
	}

	/**
	 * ----------------------------------------------------------------------------
	 * Function: test
	 * @user Chris Bestall
	 * @date 3/26/2015
	 * @output false
	 * @description ""
	 * ----------------------------------------------------------------------------
	*/
	remote string function test(   ) returnformat="plain" {

		LOCAL.output = "";
		var chart = init(  );

		savecontent variable="LOCAL.output" {

			var chart = init(  );
			writeOutput(chart.setBarChart(  )
					    .setSize(  )
					    .setTitle( "Testing" )
					    .addMarkers()
					    .addSeries( "1, 2, 3, 5, 4, 2, 3, 4" )
					    .addSeriesLabel("New")
					    .addXLabels( "Red, Blue, Green, Yellow, Purple, Orange, Black, White" )
					    .addSeries( "6, 3, 7, 2, 6, 7, 5, 3" )
					    .addSeriesLabel("Old")
					    .generate(  ));

			writeOutput("<br />");

			var chart = init(  );
			writeOutput(chart.setLineChart(  )
					    .setSize(  )
					    .setTitle( "Testing" )
					    .addMarkers()
					    .addSeries( "1, 2, 3, 5, 4, 2, 3, 4" )
					    .addSeriesLabel("New")
					    .addXLabels( "Red, Blue, Green, Yellow, Purple, Orange, Black, White" )
					    .addSeries( "6, 3, 7, 2, 6, 7, 5, 3" )
					    .addSeriesLabel("Old")
					    .generate(  ));
		}

		return LOCAL.output;

	}

	/* CHART TYPES */
	public component function setBarChart(  ){
		VARIABLES.attributes["cht"] = "bvo"; /* bvg, bhs, bvs, bvo, bhg */
		VARIABLES.attributes["chbh"] = "a";  /* Auto Bar Spacing */
		return THIS;
	}
	public component function setLineChart(  ){
		VARIABLES.attributes["cht"] = "lc"; /* lc, ls*/
		return THIS;
	}
	public component function setPieChart(  ){
		VARIABLES.attributes["cht"] = "p"; /* p, p3, pc */
		return THIS;
	}


	/* CHART SIZE */
	public component function setSize( required numeric width = 800, numeric height = 200 ){
		VARIABLES.attributes["chs"] = "#ARGUMENTS.width#x#ARGUMENTS.height#";
		return THIS;
	}
	/* CHART SIZE */
	public component function setTitle( required string title, string color = "000000", string size = "20" ){
		VARIABLES.attributes["chtt"] = URLEncodedFormat( ARGUMENTS.title );
		VARIABLES.attributes["chts"] = "#ARGUMENTS.color#,#ARGUMENTS.size#";
		return THIS;
	}
	/* CHART MARKERS */
	private component function showMarkers( ){
		if( !structKeyExists( VARIABLES.attributes, "chm" ) ){ structInsert( VARIABLES.attributes, "chm", "" ); }
		return THIS;
	}
	public component function addMarkers(  ){
		showMarkers(  );
		LOCAL.markerFormat = "N*f0zs,000000,{},-1,12,,t::-10";
		if( structKeyExists( VARIABLES.attributes, "chm" ) ){
			VARIABLES.attributes["chm"] = listAppend( VARIABLES.attributes["chm"], replaceNoCase( LOCAL.markerFormat, "{}", VARIABLES.chartSeriesIndex - 1 ), "|" ); /* 0 based index vs 1 based index */
		}
		return THIS;
	}
	public component function addFlag( required string flagText, numeric yCoord ){
		showMarkers(  );
		if(NOT structKeyExists(ARGUMENTS, "yCoord")){
			ARGUMENTS.yCoord = -1;
		}
		LOCAL.markerFormat = "f#ARGUMENTS.flagText#,000000,{},#ARGUMENTS.yCoord#,10";
		if( structKeyExists( VARIABLES.attributes, "chm" ) ){
			VARIABLES.attributes["chm"] = listAppend( VARIABLES.attributes["chm"], replaceNoCase( LOCAL.markerFormat, "{}", VARIABLES.chartSeriesIndex - 1 ), "|" ); /* 0 based index vs 1 based index */
		}
		return THIS;
	}
	public component function addLineMarker( numeric yCoord ){
		showMarkers(  );
		if(NOT structKeyExists(ARGUMENTS, "yCoord")){
			ARGUMENTS.yCoord = 0;
		}
		LOCAL.markerFormat = "D,000000,{},#ARGUMENTS.yCoord#,1";
		if( structKeyExists( VARIABLES.attributes, "chm" ) ){
			VARIABLES.attributes["chm"] = listAppend( VARIABLES.attributes["chm"], replaceNoCase( LOCAL.markerFormat, "{}", VARIABLES.chartSeriesIndex - 1 ), "|" ); /* 0 based index vs 1 based index */
		}
		return THIS;
	}



	/* CHART SERIES */
	public component function addSeries( required string dataString ){
		LOCAL.data = REreplaceNoCase( ARGUMENTS.dataString, " ?, ?", ",", "all" );
		VARIABLES.attributes["chd"] = listAppend( VARIABLES.attributes["chd"], "#LOCAL.data#", "|" );
		VARIABLES.attributes["chco"] = listAppend( VARIABLES.attributes["chco"], VARIABLES.chartColors[VARIABLES.chartSeriesIndex++], "," );
		if( VARIABLES.chartSeriesIndex == 2 ){ VARIABLES.attributes["chd"] = "t:" & VARIABLES.attributes["chd"]; }
		addMarkers(  );
		return THIS;
	}
	/* CHART SERIES TITLES */
	public component function addSeriesLabel( required string seriesLabel ){
		if( !structKeyExists( VARIABLES.attributes, "chdl" ) ){ structInsert( VARIABLES.attributes, "chdl", "" ); }
		VARIABLES.attributes["chdl"] = listAppend( VARIABLES.attributes["chdl"], "#ARGUMENTS.seriesLabel#", "|" );
		return THIS;
	}

	/* CHART SERIES TITLES */
	public component function addXLabels( required string labelValues ){
		LOCAL.labels = REreplaceNoCase( ARGUMENTS.labelValues, " ?, ?", "|", "all" );
		VARIABLES.attributes["chxl"] = listAppend( VARIABLES.attributes["chxl"], "0:|#LOCAL.labels#", "|" );
		return THIS;
	}
	/* CHART SERIES TITLES */
	public component function addYLabels( required string labelValues ){
		LOCAL.labels = REreplaceNoCase( ARGUMENTS.labelValues, " ?, ?", "|", "all" );
		VARIABLES.attributes["chxl"] = listAppend( VARIABLES.attributes["chxl"], "1:|#LOCAL.labels#", "|" );
		return THIS;
	}


	/**
	 * ----------------------------------------------------------------------------
	 * Function: generate
	 * @user Chris Bestall
	 * @date 3/27/2015
	 * @output false
	 * @description "Generate the IMG tag"
	 * ----------------------------------------------------------------------------
	*/
	public string function generate(    ){
		LOCAL.tag = "<img src=""#VARIABLES.gChartURL#{}"" />";

		return replaceNoCase( LOCAL.tag, "{}", generateURL(  ) );
	}
	/**
	 * ----------------------------------------------------------------------------
	 * Function: generate
	 * @user Chris Bestall
	 * @date 3/26/2015
	 * @output false
	 * @description "Generates the HTML string to render the Google Chart"
	 * ----------------------------------------------------------------------------
	*/
	private string function generateURL( ){
		LOCAL.html = "";

		for(item in VARIABLES.attributes) {
		   LOCAL.html = listAppend( LOCAL.html, "#item#=#VARIABLES.attributes[item]#", "&" );
		}

		// chd=t:#valueList( LOCAL.test.annualMetrics.hours )#|#valueList( LOCAL.test.annualMetrics.visits )#&chtt=Monthly%20Visits&chts=000000,20&chco=4D89F9,76A4FB&chxt=x,y&chxl=0:|#valueList( LOCAL.test.annualMetrics.month, "|" )#" />

		return LOCAL.html;
	}

}
