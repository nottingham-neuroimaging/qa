function generateHTMLReport(scanParams)


% ============ Create index page..

fileID = fopen('QA_report/index.html','w');

% Make the header first

fprintf(fileID,'%s','<html><title>QA Report</title><h1>Quality Assurance report: </h1>');
% Make the table:
fprintf(fileID,'%s','<table><tr><td width=300px><a href="tSNR.html"><h2>tSNR report</h2></a></td>');
fprintf(fileID,'%s',['<td><a href="tSNR.html"><img src=' scanParams(1).fileName(1:end-4) '_tSNR_IMAGE.png width=200></a></td></tr>']);
fprintf(fileID,'\n');
fprintf(fileID,'%s','<table><tr><td width=300px><a href="mean.html"><h2>Mean Images</h2></a></td>');
fprintf(fileID,'%s',['<td><a href="mean.html"><img src=' scanParams(1).fileName(1:end-4) '_Mean_IMAGE.png width=200></a></td></tr>']);
fprintf(fileID,'%s','</table>');
fprintf(fileID,'%s','</html>');

fclose(fileID);

% ============ Now create tSNR page..

fileID = fopen('QA_report/tSNR.html','w');

% Make the header first

fprintf(fileID,'%s','<html><title>tSNR report</title><h1>SCAN: </h1>');


for nf=1:length(scanParams)
    fprintf(fileID,'%s',['<h2>' scanParams(nf).fileName '</h2><br>']);
    fprintf(fileID,'%s',['<a href=' scanParams(nf).fileName(1:end-4) '_tSNR_IMAGE.png>'  ...
        '<img src=' scanParams(nf).fileName(1:end-4) '_tSNR_IMAGE.png width=800></a> <br>' ]);
    fprintf(fileID,'%s',['<img src=cbar.png width=400><br>']);
    fprintf(fileID,'%s',['Notes: ' scanParams(nf).notes '<br><br><br>']);
end

fprintf(fileID,'%s','</html>');

fclose(fileID);


% ============== Now create the Mean Image page...

fileID = fopen('QA_report/mean.html','w');
% Make the header first
fprintf(fileID,'%s','<html><title>Mean Images</title><h1>SCAN: </h1>');

for nf=1:length(scanParams)
    fprintf(fileID,'%s',['<h2>' scanParams(nf).fileName '</h2><br>']);
    fprintf(fileID,'%s',['<a href=' scanParams(nf).fileName(1:end-4) '_Mean_IMAGE.png>'  ...
        '<img src=' scanParams(nf).fileName(1:end-4) '_Mean_IMAGE.png width=800></a> <br>' ]);    
    fprintf(fileID,'%s',['Notes: ' scanParams(nf).notes '<br><br><br>']);
end

fprintf(fileID,'%s','</html>');
fclose(fileID);

% Wrap up with a message!

fprintf('<a href = "%s">%s</a>\n',[pwd '/QA_report/index.html'],'QA report html')
end