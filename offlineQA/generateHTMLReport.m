function generateHTMLReport(scanParams)


% ============ Create index page..

fileID = fopen('QA_report/index.html','w');

% Make the header first
[path,file] = fileparts(which('generateHTMLReport.m'));
copyfile([path filesep 'websiteStyle.css'],'QA_report/')


fprintf(fileID,'%s','<html><title>QA Report</title>');
fprintf(fileID,'%s','<head><link rel="stylesheet" href="websiteStyle.css"></head><div id="header"><h1>Quality Assurance report: </h1><div id="navigation"><a href="index.html">Summary</a></div></div>');
fprintf(fileID,'\n');
fprintf(fileID,'%s','<div id="content">');
% Make the table:
fprintf(fileID,'%s','<br><br><center><table><tr><td width=300px><a href="tSNR.html"><h2>tSNR report</h2></a></td>');
fprintf(fileID,'%s',['<td><a href="tSNR.html"><img src=' scanParams(1).outputBaseName '_tSNR_IMAGE.png width=200></a></td></tr>']);
fprintf(fileID,'\n');
fprintf(fileID,'%s','<tr><td width=300px><a href="mean.html"><h2>Mean Images</h2></a></td>');
fprintf(fileID,'%s',['<td><a href="mean.html"><img src=' scanParams(1).outputBaseName '_Mean_IMAGE.png width=200></a></td></tr>']);
fprintf(fileID,'\n');
	if(scanParams(1).createFSreport_html)
		fprintf(fileID,'%s','<tr><td width=300px><a href="fssurface.html"><h2>tSNR on Freesurfer surfaces</h2></a></td>');
		fprintf(fileID,'%s',['<td><a href="fssurface.html"><img src=' scanParams(1).outputBaseName '_tSNR_summarySurface.png width=200></a></td></tr>']);
		fprintf(fileID,'\n');
		fprintf(fileID,'%s','<tr><td width=300px><a href="fsmetrics.html"><h2>Freesurfer metrics</h2></a></td>');
		fprintf(fileID,'%s',['<td><a href="fsmetrics.html"><img src=tSNR_line_left.png width=200></a></td></tr>']);
		fprintf(fileID,'\n');
	end
fprintf(fileID,'%s','</table>');
fprintf(fileID,'%s','</center></div>');
fprintf(fileID,'%s','</html>');

fclose(fileID);

% ============ Now create tSNR page..

fileID = fopen('QA_report/tSNR.html','w');

% Make the header first
fprintf(fileID,'%s','<html>');%<h1>SCAN: </h1>');
fprintf(fileID,'%s','<head><link rel="stylesheet" href="websiteStyle.css"></head><div id="header"><h1>Quality Assurance report: </h1><div id="navigation"><a href="index.html">Summary</a></div></div>');
fprintf(fileID,'\n');
fprintf(fileID,'%s','<div id="content">');

fprintf(fileID,'%s','<br><h2>tSNR</h2>');

for nf=1:length(scanParams)
    fprintf(fileID,'%s',['<h3>' scanParams(nf).fileName '</h3><br>']);
    fprintf(fileID,'%s',['<center><a href=' scanParams(nf).outputBaseName '_tSNR_IMAGE.png>'  ...
        '<img src=' scanParams(nf).outputBaseName '_tSNR_IMAGE.png width=800></a> <br>' ]);
    fprintf(fileID,'%s',['<img src=cbar.png height=50><br><a href=' scanParams(nf).outputBaseName '_tSNR_HIST.png><img src=' scanParams(nf).outputBaseName '_tSNR_HIST.png height=80></a><br></center>']);
    fprintf(fileID,'%s',['<p> Notes: ' scanParams(nf).notes '</p></center><br><br><br>']);
end

fprintf(fileID,'%s','</div>');

fprintf(fileID,'%s','</html>');

fclose(fileID);


% ============== Now create the Mean Image page...

fileID = fopen('QA_report/mean.html','w');
% Make the header first
fprintf(fileID,'%s','<html><title>Mean Images</title>');
fprintf(fileID,'%s','<head><link rel="stylesheet" href="websiteStyle.css"></head><div id="header"><h1>Quality Assurance report: </h1><div id="navigation"><a href="index.html">Summary</a></div></div>');
fprintf(fileID,'\n');
fprintf(fileID,'%s','<div id="content">');
fprintf(fileID,'%s','<br><h2>Mean Images</h2>');

for nf=1:length(scanParams)
    fprintf(fileID,'%s',['<h3>' scanParams(nf).fileName '</h3><br>']);
    fprintf(fileID,'%s',['<center><a href=' scanParams(nf).outputBaseName '_Mean_IMAGE.png>'  ...
        '<img src=' scanParams(nf).outputBaseName '_Mean_IMAGE.png width=800></a> <br>' ]);    
    fprintf(fileID,'%s',['<p>Notes: ' scanParams(nf).notes '</p></center><br><br><br>']);
end
fprintf(fileID,'%s','</div>');
fprintf(fileID,'%s','</html>');
fclose(fileID);

if(scanParams(1).createFSreport_html)
	% ============== Now create the fsmetrics page!...

	fileID = fopen('QA_report/fsmetrics.html','w');
	% Make the header first
	fprintf(fileID,'%s','<html><title>Freesurfer Metrics Report</title>');
	fprintf(fileID,'%s','<head><link rel="stylesheet" href="websiteStyle.css"></head><div id="header"><h1>Quality Assurance report: </h1><div id="navigation"><a href="index.html">Summary</a></div></div>');
	fprintf(fileID,'\n');
	fprintf(fileID,'%s','<div id="content">');
	fprintf(fileID,'%s','<br><h2>Freesurfer Metrics</h2>');
	fprintf(fileID,'%s','<center><br><h3>tSNR GM</h3></center>');
	fprintf(fileID,'%s',['<br><br><center><table width=700><tr>']);
	fprintf(fileID,'%s',['<td><a href=tSNR_bar_left.png>'  ...
        '<img src=tSNR_bar_left.png width=350></a></td>' ]); 
	fprintf(fileID,'%s',['<td><a href=tSNR_bar_right.png>'  ...
        '<img src=tSNR_bar_right.png width=350></a></td>' ]); 
	fprintf(fileID,'%s',['</tr></center></table><br><br>']);
	fprintf(fileID,'%s',['<h3>tSNR white Matter</h3><br>']);
    fprintf(fileID,'%s',['<center><a href=tSNR_wm.png>'  ...
        '<img src=tSNR_wm.png width=800></a> <br>' ]); 

	fprintf(fileID,'%s','<center><br><h3>tSNR GM Ranked by highest tSNR</h3></center>');
	fprintf(fileID,'%s',['<br><br><center><table width=700><tr>']);
	fprintf(fileID,'%s',['<td><a href=tSNR_line_left.png>'  ...
        '<img src=tSNR_line_left.png width=700></a></td></tr>' ]); 
	fprintf(fileID,'%s',['<tr><td><a href=tSNR_line_right.png>'  ...
        '<img src=tSNR_line_right.png width=700></a></td>' ]); 
	fprintf(fileID,'%s',['</tr></center></table><br><br>']);
	fprintf(fileID,'%s','</div>');
	fprintf(fileID,'%s','</html>');
	fclose(fileID);
end



if(scanParams(1).createFSreport_html)
	% ============== Now create the fs-surface page!...

	fileID = fopen('QA_report/fssurface.html','w');
	% Make the header first
	fprintf(fileID,'%s','<html><title>Freesurfer Metrics Report</title>');
	fprintf(fileID,'%s','<head><link rel="stylesheet" href="websiteStyle.css"></head><div id="header"><h1>Quality Assurance report: </h1><div id="navigation"><a href="index.html">Summary</a></div></div>');
	fprintf(fileID,'\n');
	fprintf(fileID,'%s','<div id="content">');
	fprintf(fileID,'%s','<br><h2>Freesurfer Surfaces</h2>');
	for nf=1:length(scanParams)
	    fprintf(fileID,'%s',['<h3>' scanParams(nf).fileName '</h3><br>']);
	    fprintf(fileID,'%s',['<center><a href=' scanParams(nf).outputBaseName '_tSNR_summarySurface.png>'  ...
	        '<img src=' scanParams(nf).outputBaseName '_tSNR_summarySurface.png width=800></a> <br>' ]);    
	    fprintf(fileID,'%s',['<p>Notes: ' scanParams(nf).notes '</p></center><br><br><br>']);
	end	
	fprintf(fileID,'%s','</div>');
	fprintf(fileID,'%s','</html>');
	fclose(fileID);
end

% Wrap up with a message!

fprintf('<a href = "%s">%s</a>\n',[pwd '/QA_report/index.html'],'QA report html')
end