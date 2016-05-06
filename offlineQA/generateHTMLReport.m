function generateHTMLReport(scanParams)

fileID = fopen('QA_report/index.html','w');

% Make the header first

fprintf(fileID,'%s','<html><title>QA Report</title><h1>SCAN: </h1>');


for nf=1:length(scanParams)
fprintf(fileID,'%s',['<h2>' scanParams(nf).fileName '</h2><br>']);
fprintf(fileID,'%s',['<a href=' scanParams(nf).fileName(1:end-4) '_tSNR_IMAGE.png>'  ...
    '<img src=' scanParams(nf).fileName(1:end-4) '_tSNR_IMAGE.png width=800></a> <br>' ]);
fprintf(fileID,'%s',['<img src=cbar.png width=400><br>']);
fprintf(fileID,'%s',['Notes: ' scanParams(nf).notes '<br><br><br>']);
end

fprintf(fileID,'%s','</html>');

fclose(fileID);

fprintf('<a href = "%s">%s</a>\n',[pwd '/QA_report/index.html'],'QA report html')
end