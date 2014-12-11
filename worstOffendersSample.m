load('UniPR.mat');
fileID = fopen('worstOffendersSample.txt', 'w');
fprintf(fileID, 'Reference\tJournalTitle\tPRTitle\tSample_journal\tSample_PR\n');

% Loop through struct and check if sample changes between journal and PR
for n=1:462,
    % PR sample different from abstract of journal is coded as 2
    if PRs(n).PR.Sample.SameAsAbstract == 2
        % create strings for writing to file
	    reference = strrep(PRs(n).Info.Reference,sprintf('\n'),' ');
	    journalTitle = strrep(PRs(n).Info.JournalTitle,sprintf('\n'),' ');
	    PRTitle = strrep(PRs(n).Info.PRTitle,sprintf('\n'), ' ');
	    sample_Journal = strrep(PRs(n).Journal.Sample.Sample,sprintf('\n'), ' ');
	    sample_PR = strrep(PRs(n).PR.Sample.Sample,sprintf('\n'), ' ');
        % write strings to file
	    fprintf(fileID, '%s\t%s\t%s\t%d: %s\t%d: %s\n', reference, journalTitle, ...
            PRTitle, PRs(n).Journal.Sample.Code, sample_Journal, ...
            PRs(n).PR.Sample.Code, sample_PR);
    end 
        
end
fclose(fileID);

