load('UniPR.mat');
universities = char('Birmingham', 'Bristol', 'Cambridge', ...
    'Cardiff', 'Edinburgh', 'Glasgow', 'Imperial', ...
    'Kings','Leeds', 'Liverpool', 'LSE', 'Manchester', ...
    'Newcastle', 'Nottingham', 'Oxford','Queens Belfast', ...
    'Sheffield', 'Southampton', 'UCL', 'Warwick');

% file to write to
fileID = fopen('allMainData.tsv', 'w');
fprintf(fileID, 'Reference\tUniversity\tJournalTitle\tAuthors\tPRTitle\tSample_journal\tSample_PR\tAdvice_exaggeration\tCausation_exaggeration\tVariable_generalization\t"Cure"\n');

% Loop through struct and check if sample changes between journal and PR
for n=1:462,
    disp(n)
    % get code of uni
    string = char(PRs(n).Info.Reference);
    code = str2num(string(1:2)); 
    university = universities(code, :);
    
    % create strings for writing to file
    reference = strrep(PRs(n).Info.Reference,sprintf('\n'),' ');
    journalTitle = strrep(PRs(n).Info.JournalTitle,sprintf('\n'),' ');
    PRTitle = strrep(PRs(n).Info.PRTitle,sprintf('\n'), ' ');
    sample_Journal = strrep(PRs(n).Journal.Sample.Sample,sprintf('\n'), ' ');
    sample_PR = strrep(PRs(n).PR.Sample.Sample,sprintf('\n'), ' ');
    
    
    % get details of authors from PubMed
    search_term =strrep(journalTitle,sprintf(' '), '%5BTitle%5D+AND+');
    search_term = strcat(search_term, '%5BTitle%5D');
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
    
    % variable generalization score = sum of generalization scores for main variable pair
    variableGeneralization = PRs(n).PR.IV1.Generalized.Generalized + ...
        PRs(n).PR.DV1.Generalized.Generalized;
    
    % causation exaggeration score
    causationExaggeration = PRs(n).PR.Statement1.Code - PRs(n).Journal.Statement1.Code;

    % also see whether the advice was exaggerated (higher score is more
    % explicit)
    adviceExaggerated =  PRs(n).PR.Advice.Code-PRs(n).Journal.Advice.Code;  
    
    % and if the word "cure" was used in the press release
    cure = PRs(n).PR.Cure;

    % write strings to file
    fprintf(fileID, '%s\t%s\t%s\t%s\t%s\t%d: %s\t%d: %s\t%d\t%d\t%d\t%d\n', ...
        reference, university, journalTitle, authors, PRTitle, ...       
        PRs(n).Journal.Sample.Code, sample_Journal, ...
        PRs(n).PR.Sample.Code, sample_PR, adviceExaggerated, ...
         causationExaggeration, variableGeneralization, cure);
        
     
        
end
fclose(fileID);

