load('UniPR.mat');
universities = char('Birmingham', 'Bristol', 'Cambridge', ...
    'Cardiff', 'Edinburgh', 'Glasgow', 'Imperial', ...
    'Kings','Leeds', 'Liverpool', 'LSE', 'Manchester', ...
    'Newcastle', 'Nottingham', 'Oxford','Queens Belfast', ...
    'Sheffield', 'Southampton', 'UCL', 'Warwick');
concordantScores = char('Same', 'Weaker', 'Stronger', 'NA');

% file to write to
fileID = fopen('sampleMisrepresented.txt', 'w');
fprintf(fileID, 'Reference\tUniversity\tJournalTitle\tAuthors\tPRTitle\tSample_journal\tSample_PR\tAdvice_exaggeration\n');

% Loop through struct and check if sample changes between journal and PR
for n=1:462,
    disp(n)
    % get code of uni
    string = char(PRs(n).Info.Reference);
    code = str2num(string(1:2)); 
    university = universities(code, :);
    
    % PR sample different from abstract of journal is coded as 2
    if PRs(n).PR.Sample.SameAsAbstract == 2
        % create strings for writing to file
	    reference = strrep(PRs(n).Info.Reference,sprintf('\n'),' ');
	    journalTitle = strrep(PRs(n).Info.JournalTitle,sprintf('\n'),' ');
	    PRTitle = strrep(PRs(n).Info.PRTitle,sprintf('\n'), ' ');
	    sample_Journal = strrep(PRs(n).Journal.Sample.Sample,sprintf('\n'), ' ');
	    sample_PR = strrep(PRs(n).PR.Sample.Sample,sprintf('\n'), ' ');
        
        % get details of authors from PubMed
        search_term =strrep(journalTitle,sprintf(' '), '+');
        pubmed_data = vertcat(getpubmed(search_term));
        if size(pubmed_data) == [1 1]
            if isempty(pubmed_data.Authors) == 0
                authors = strjoin(pubmed_data.Authors, ',');
            else
                authors = '--no PubMed data found--';
            end
        else
            authors = '--too many PubMed results--';
        end
        
        % also see whether the advice was exaggerated (higher score is more
        % explicit)
        adviceExaggerated =  PRs(n).PR.Advice.Code-PRs(n).Journal.Advice.Code;        
       
        % write strings to file
	    fprintf(fileID, '%s\t%s\t%s\t%s\t%s\t%d: %s\t%d: %s\t%f\n', reference, ...
            university, journalTitle, authors, ...       
    PRTitle, PRs(n).Journal.Sample.Code, sample_Journal, ...
            PRs(n).PR.Sample.Code, sample_PR, adviceExaggerated);
        
    end 
        
end
fclose(fileID);

