load('UniPR.mat');
universities = char('Birmingham', 'Bristol', 'Cambridge', ...
    'Cardiff', 'Edinburgh', 'Glasgow', 'Imperial', ...
    'Kings','Leeds', 'Liverpool', 'LSE', 'Manchester', ...
    'Newcastle', 'Nottingham', 'Oxford','Queens Belfast', ...
    'Sheffield', 'Southampton', 'UCL', 'Warwick');

% file to write to
fileID = fopen('mainData.tsv', 'w');
headerString = ['Reference\tUniversity\tJournalTitle\t',...
    'Authors\tPRTitle\t',...
    'Sample_changed\tSample_journal\tSample_PR\t',...
    'Advice_exaggeration\tAdvice_journal\tAdvice_PR\t',...
    'Causation_exaggeration\tCausation_journal\tCausation_PR\t',...
    'Variables_generalization\tVariables_journal\tVariables_PR\t',...
    '"Cure"\n'];
fprintf(fileID, headerString);

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
    variableGeneralization = num2str(PRs(n).PR.IV1.Generalized.Generalized + ...
        PRs(n).PR.DV1.Generalized.Generalized);
    variableJournal = strrep(PRs(n).Journal.IV1.IV,sprintf('\n'), ' ');
    variableJournal = strcat(variableJournal, '/');
    variableJournal = strcat(variableJournal, strrep(PRs(n).Journal.DV1.DV,sprintf('\n'), ' '));
    variablePR = strrep(PRs(n).PR.IV1.IV,sprintf('\n'), ' ');
    variablePR = strcat(variablePR, '/');
    variablePR = strcat(variablePR, strrep(PRs(n).PR.DV1.DV,sprintf('\n'), ' '));
    
    % causation exaggeration score
    causationPR = num2str(PRs(n).PR.Statement1.Code);
    causationJournal = num2str(PRs(n).Journal.Statement1.Code);
    causationExaggeration = num2str(PRs(n).PR.Statement1.Code - ...
        PRs(n).Journal.Statement1.Code);
    if causationPR == '0'
        causationPR = 'Not mentioned'
    end

    if causationJournal == '0'
        causationJournal = 'Not mentioned'
    end
   
    
    % also see whether the advice was exaggerated (higher score is more
    % explicit)
    adviceExaggerated =  PRs(n).PR.Advice.Code-PRs(n).Journal.Advice.Code;  
    adviceJournal = PRs(n).Journal.Advice.Code;
    advicePR = PRs(n).PR.Advice.Code;
    % and if the word "cure" was used in the press release
    cure = PRs(n).PR.Cure;
    cureString = 'NA';
    if cure==0
        cureString='No';
    elseif cure==1
        cureString='Unrelated';
    elseif cure==2
        cureString='"No cure"';
    elseif cure==3
        cureString='"Cure"';
    end

    % see if the sample changed from journal to PR
    sampleChanged = PRs(n).PR.Sample.SameAsAbstract;
    if sampleChanged == 0
        sampleChanged = 'No';
    end
    if sampleChanged == 1
        sampleChanged = 'Minor';
    end
    if sampleChanged == 2
        sampleChanged == 'Major';
    end

    % write strings to file
    entryString = ['%s\t%s\t%s\t',...
    '%s\t%s\t',...
    '%d\t%d: %s\t%d: %s\t',...
    '%d\t%d\t%d\t',...
    '%s\t%s\t%s\t',...
    '%s\t%s\t%s\t',...
    '%s\n'];
    fprintf(fileID,['%s\t%s\t%s\t',...
    '%s\t%s\t',...
    '%s\t%d: %s\t%d: %s\t',...
    '%d\t%d\t%d\t',...
    '%s\t%s\t%s\t',...
    '%s\t%s\t%s\t',...
    '%s\n'], ...
        reference, university, journalTitle,...
        authors, PRTitle, ...       
        sampleChanged, PRs(n).Journal.Sample.Code, sample_Journal, PRs(n).PR.Sample.Code, sample_PR,...
        adviceExaggerated, adviceJournal, advicePR, ...
        causationExaggeration, causationJournal, causationPR,...
        variableGeneralization, variableJournal, variablePR,...
        cureString);
        
end
fclose(fileID);

