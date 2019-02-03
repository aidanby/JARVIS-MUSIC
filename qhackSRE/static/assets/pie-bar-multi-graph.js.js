multiGraphChart = function(config, obj){
	var duration = 500;
	var self = this;
	var uniqueId = config.uniqueIdentifier || config.labelProp;
	var marginV = config.marginV?config.marginV:30;
	var marginH = config.marginH?config.marginH:0;
	var ratio = config.ratio?config.ratio:0.5;
	this.totalObj = [];
	var totalHeight = config.height - 2*(marginV);
	var totalWidth = config.width - 2*(marginH);
	var textOffset = config.textOffsetHeight || 30;
	var barGraphWidth = ratio*totalWidth; //width assigned to bar graph svg element
	var pieWidth = totalWidth - barGraphWidth;	// width assigned to pie chart svg element
	var netBarGraphWidth = barGraphWidth-marginH;
	var barColor = 'steelblue';
	var groupScaleProp = 'id';
	var unitWidth = 0;
	var totalBars = 0;
	self.keys = {};
	self.groupBarCountMap = {};
	var p = config.barPadding || 0.1,	//padding between bars
		gp = config.groupPadding || 30;	//padding between groups

	var gs = {},	//group scale
		bs = {};	//bar scale
	// creates a linear scale to scale down(up) bar's height in accordance to container's height
	var y = d3.scale.linear()
			.range([totalHeight-textOffset,0]);

	/*
		This scale will linearly scale down all the values in pie chart between specified range
		This will indirectly create a minimum angle for a path
	 */
	var pathScale = d3.scale.linear().range([7,360]);
	this.scale = pathScale;

	// pie layout
	var pieLayout = d3.layout.pie()
						.value(function(d){ return pathScale(d[config.valueProp]) });
	// scale for color's of pie chart
	var pieColor = d3.scale.ordinal()
						.range(["#807dba","#ff7f0e",'#2ca02c','#2196f3','#f8e71c','#7f7f7f','#91d948','#8f7540']);

	function init(){
		var container = d3.select(config.id)
							.attr('id','graph-chart-multi');

		//svg container for bar graph
		self.chart = container.append('svg')
						.attr('width', barGraphWidth)
						.attr('height', config.height)
						.attr('id','graph-chart-multi-bar-svg')
						.append('g')
						.attr('transform', "translate("+marginH+","+marginV+")");

		self.barGroup = self.chart.append('g')
							.attr('transform', "translate(0,0)")

		self.bottomLabelGroup = self.chart.append('g')
									.attr('transform', "translate(0,"+(totalHeight-textOffset)+")")
									.attr('class', 'bottom-label-group')

		//creating svg container for pie chart
		self.pieGroup = container.append('svg')
							.attr('id', 'pie-chart-svg')
							.attr('x', barGraphWidth)
							.attr('height',totalHeight)
							.attr('width', pieWidth)
							.append('g')
							.attr('transform', "translate("+pieWidth/2+","+(totalHeight/2)+")");

		self.totalObj = calculateGraphTotal(obj); //adds up all inner most object values and creates a single 3 level object

		//creating a table container for legend
		self.legendGroup = container.append('div')
									.attr('id','legend-table')
									.append('table')
									.attr('class','legend');
	}

	//Runs first time and creates an object having the total of
	// values under config.subLabel
	function calculateGraphTotal(data){
		var temp = {};
		var total = 0;
		for(var i in data){
			if(data.hasOwnProperty(i)){
				var sub = data[i][config.subProp];
				sub.forEach(function(s){ //Inside second level
					var parentName = s[uniqueId];
					if(!temp[parentName]) temp[parentName] = {}; // Creating parent property as in original structure
					s[config.subProp].forEach(function(item,index){ //Inside third level
						self.keys[index] = true;
						if(!temp[parentName][item[config.labelProp]]) temp[parentName][item[config.labelProp]] = 0;
						temp[parentName][item[config.labelProp]]+=item[config.valueProp];
					})
				})
				total+=data[i][config.valueProp];
			}
		}
//		console.log(JSON.parse(JSON.stringify(temp)));
		var arr = [];
		//adding a 'percent' property to passed in data
		for(var i in data){
			if(data.hasOwnProperty(i)){
				data[i]['percent'] = Math.round(data[i][config.valueProp]/total*100);
			}
		}
		self.keys = Object.keys(self.keys);

		self.groupBarCountMap = createMap(temp);

		for(var sub in temp){
			if(temp.hasOwnProperty(sub)){
				var parent = {};	//creates an object with labelProp and subProp (an array)
				parent[config.labelProp] = sub;
				var a = [];
				// if(!self.keys) self.keys = Object.keys(temp[sub]);
				for(var t in temp[sub]){
					if(temp[sub].hasOwnProperty(t)){
						var buffer = {};
						buffer[config.labelProp] = t;
						buffer[config.valueProp] = temp[sub][t];
						a.push(buffer);
					}
				}
				parent[config.subProp] = a;
			}
			arr.push(parent);
		}
		return arr;	//returns an array of object having all groups with numbers added up
	}

	/**
	 * Returns an object which has a mapping between each group (uniqueId) and total number of inner objects it has (bars)
	 * @param  {Object} data Object with key as group unique identifier and value an array of objects (bars)
	 */
	function createMap(data){
		var map = {};
		var count = 0;	//counts number of bars
		for(var i in data){
			if(data.hasOwnProperty(i)){
				map[i] = Object.keys(data[i]).length;
				count+=map[i];
			}
		}
		totalBars = count;
		return map;
	}

	/*
		Creates a custom linear scale for bar groups. Unlike d3's default linear scale which equally divides space between groups
		irrespective of number of inner objects, this scale will divide space based on the number of inner objects (bars) a group contains
	 */
	function createGroupScale(map){
		var x={},
			width = {},
			count = 0;
		//assuming each bar to be a unit for a group and adding up all bar's for each group to get width of that group and finding that unit dimension
		unitWidth = Math.round((netBarGraphWidth - (Object.keys(map).length-1)*gp)/totalBars);

		for(var i in map){
			if(map.hasOwnProperty(i)){
				width[i] = map[i] * unitWidth;
				x[i] = count;
				count+=width[i]+gp;
			}
		}
		return {
			getWidth: function(id){
				return width[id];
			},
			getX: function(id){
				return x[id];
			}
		}
	}

	/*
		Creates a linear scale for bars inside each group. Independent scale is created for each group. Width of bar remains the same throught.
	 */
	function createBarScale(gs, map, ratio){
		var p = unitWidth*ratio;
		var b = unitWidth - p;
		var x = {};
		for(var i in map){
			if(map.hasOwnProperty(i)){
				var n = map[i];
				x[i] = {};
				var gw = gs.getWidth(i);	//width of ith group
				switch (n%2) {
					case 0:	var middleNode = n/2;	//if even number of bars
							var counter = gw/2 - (b + p/2);
							//for nodes before middleNode
							for(var c=middleNode-1; c>=0; c--){
								x[i][c] = counter;
								counter-= p+b;
							}
							//for nodes after middleNode
							counter = gw/2 + p/2;
							for(var c=middleNode; c<n; c++){
								x[i][c] = counter;
								counter+= p+b;
							}
							break;

					case 1:	var middleNode = parseInt(n/2) + 1;	//if odd number of bars
							var counter = gw/2 - b/2;
							//for nodes before middleNode
							for(var c=middleNode-1; c>=0; c--){
								x[i][c] = counter;
								counter-= p+b;
							}
							counter = gw/2 + b/2 + p;
							for(var c=middleNode; c<n; c++){
								x[i][c] = counter;
								counter+= p+b;
							}
							break;
				}
			}
		}
		return {
			getX: function(id, i){
				return x[id][i];
			},
			getWidth: function(){
				return b;
			}
		}
	}

	function createChart(data){
		createBarGraph(self.totalObj);
		createPieChart(data);
		createLegend(data);
	}

	function createBarGraph(data){
		gs = createGroupScale(self.groupBarCountMap);
		bs = createBarScale(gs, self.groupBarCountMap, p);
		y.domain([0, d3.max(data, function(d){
			return d3.max(d[config.subProp], function(ds){ return ds[config.valueProp] });
		})]);
		self.chart.select('g.x.axis').remove('*');
		var bar = self.barGroup.selectAll('g')
					.data(data);
		var barEnter = bar.enter().append('g');

		bar.attr('class', 'bar')
			.attr('transform', function(d,i){
				return "translate("+gs.getX(d[uniqueId])+",0)";
			});

		// create's bars based on data
		bar.selectAll('rect')
			.data(function(d){ return d[config.subProp]; })
			.enter().append('rect')
			.attr('x', function(d,i){ var id = d3.select(this.parentNode).datum()[uniqueId]; return bs.getX(id, i); })
			.attr('y', function(d){ return y(d[config.valueProp]); })
			.attr('width', bs.getWidth())
			.attr('height', function(d){ return totalHeight - textOffset - y(d[config.valueProp]); })
			.attr('fill',barColor)

		// creates text field above each bar
		bar.selectAll("text")
			.data(function(d){ return d[config.subProp]; })
			.enter().append('text')
			.attr('x', function(d,i){
				var id = d3.select(this.parentNode).datum()[uniqueId];
				var r = bs.getX(id,i) + bs.getWidth()/2;
				return r;
			})
			.attr("y", function(d) { return y(d[config.valueProp]) - 3; })
			.attr('text-anchor', 'middle')
			.text(function(d) { return d[config.valueProp]; });

		bar.exit().remove();

		//Adding bottom labels for individual bars
		var labels = self.bottomLabelGroup.selectAll('g')
						.data(data)
						.enter().append('g')
						.attr('transform', function(d,i){
							return "translate("+gs.getX(d[uniqueId])+",0)";
						});

		labels.selectAll('text')
			.data(function(d){ return d[config.subProp]; })
			.enter().append('text')
			.attr('x', function(d,i){ var id = d3.select(this.parentNode).datum()[uniqueId]; return (bs.getX(id,i) + bs.getWidth()/2); })
			.attr("y", function(d) { return 12; })
			.attr('text-anchor', 'middle')
			// .text(function(d){ return d[config.labelProp]; })
			.each(wrapText);

		//Adding horizontal axis labelling each bar group
		self.barGroups = self.chart.append('g')
							.attr("transform", "translate(0," + totalHeight + ")")
							.attr("class", "x axis")

		self.barGroups.selectAll('g')
			.data(data)
			.enter().append('g')
			.attr('transform', function(d,i){
				var id = d[uniqueId];
				var middle = gs.getX(id,i) + gs.getWidth(id)/2;
				return "translate("+middle+",0)";
			})
			.append('text')
			.text(function(d){ return d[config.labelProp]; })
			.attr('text-anchor', 'middle')
			.style({'font-size': '12px'})
	}

	function wrapText(d,index) {
	   var arr = d[config.labelProp].split(" ");
	   if (arr != undefined) {
		   for (i = 0; i < arr.length; i++) {
			   d3.select(this).append("tspan")
				   .text(arr[i])
				   .attr("dy", i ? "1.2em" : 0)
				   .attr('x', function(d){ var id = d3.select(this.parentNode.parentNode).datum()[uniqueId]; return bs.getX(id,index) + bs.getWidth()/2; })						   .attr("text-anchor", "middle")
				   .attr("class", "tspan" + i);
		   }
	   }
	}

	function updateBarGraph(data, color){
		y.domain([0, d3.max(data, function(d){
			return d3.max(d[config.subProp], function(ds){ return ds[config.valueProp] });
		})]);

		var bars = self.barGroup.selectAll('g')
						.data(data);
		var b = bars.selectAll("rect")
				.data(function(d){ return d[config.subProp]; });
		b.enter().append('rect');
		b.transition().duration(duration)
			.attr("y", function(d) {return y(d[config.valueProp]); })
			.attr("height", function(d) { return totalHeight - textOffset -y(d[config.valueProp]); })
			.attr("fill",color)

		// transition the frequency labels location and change value.
		var text = bars.selectAll("text")
					.data(function(d){ return d[config.subProp]; });
		text.enter().append('text');
		text.transition().duration(duration)
			.text(function(d){ return (d[config.valueProp])})
			.attr("y", function(d) {return y(d[config.valueProp])-3; });
	}

	function createPieChart(data){
		// var minvalue=d3.min(data,function(d){return d[config.valueProp]});
        var maxvalue=d3.max(data,function(d){return d[config.valueProp]})
        pathScale.domain([0,maxvalue]);

		var oRadius = Math.min(totalHeight, pieWidth)/2;
		var arc = d3.svg.arc()
					.innerRadius(0)
					.outerRadius(oRadius-20);
		var piePath = self.pieGroup.selectAll('path')
						.data(pieLayout(data), function(d){ return d.data.id; })
		piePath.enter().append('path');
		piePath.attr('fill', function(d){ return pieColor(d.data[uniqueId]);})
				.attr('stroke', 'white')
				.attr('stroke-width', 0.7)
				.attr('d', arc)
				.on('mouseenter', mouseEnter)
				.on('mouseleave', mouseLeave)

		piePath.exit().remove();
	}

	function createLegend(data){
		var tBody = self.legendGroup.append('tbody');
		var tr = tBody.selectAll('tr')
					.data(data)
					.enter()
					.append('tr')
					.attr('unique-attr',function(d){ return d[uniqueId]; })

		tr.append('td').append('svg').attr("width", '16').attr("height", '16')
			.append("rect").attr("width", '16').attr("height", '16')
			.attr('fill',function(d){
				return pieColor(d[uniqueId]);
			});
		tr.append('td').html(function(d){return d[config.labelProp]});
		// tr.append('td').html(function(d){return d[config.valueProp]});
		// tr.append('td').html(function(d){return d['percent']+'%';});
	}

	function mouseEnter(d){
		var color = d3.select(this)
			.attr('fill');
		updateBarGraph(d.data[config.subProp], color);
		d3.select("tr[unique-attr='"+d.data[uniqueId]+"']")
			.classed('highlight-row',true);
	}

	function mouseLeave(d){
		updateBarGraph(self.totalObj, barColor);
		d3.select("tr[unique-attr='"+d.data[uniqueId]+"']")
			.classed('highlight-row',false);
	}

	if(obj && obj.length){
		init();
		createChart(obj);
	}
}