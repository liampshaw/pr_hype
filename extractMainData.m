% Extracts information from the data made publicly available by Sumner et al. (2014)
% at http://figshare.com/articles/InSciOut/903704
% For details of variable coding, see '3. Full Coding Guidelines.pdf'.
% Author: Liam Shaw

load('UniPR.mat');

% Codes of universities (see 'Guidance sheet' in supplementary data)
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

% Loop through the data and extract the information
for n=1:462,
    disp(n) % to display progress
    
    % MAIN INFO
    % Create strings for writing to file
    reference = strrep(PRs(n).Info.Reference,sprintf('\n'),' ');
    journalTitle = strrep(PRs(n).Info.JournalTitle,sprintf('\n'),' ');
    PRTitle = strrep(PRs(n).Info.PRTitle,sprintf('\n'), ' ');
    % Get code of university from reference
    string = char(PRs(n).Info.Reference);
    code = str2num(string(1:2)); 
    university = universities(code, :);
    
    % AUTHORS
    % Get details of authors from PubMed
    pubmed_data = vertcat(getpubmed(formatTitleForPubMed(journalTitle)));
    if size(pubmed_data) == [1 1]
        if isempty(pubmed_data.Authors) == 0
            authors = strjoin(pubmed_data.Authors, ',');
        else
            authors = '--no PubMed data found--';
        end
    else
        authors = '--too many PubMed results--';
    end
    
    % SAMPLE GENERALIZATION
    % Did the sample change from journal to PR
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
    % What were the samples in journal and PR
    sample_Journal = strrep(PRs(n).Journal.Sample.Sample,sprintf('\n'), ' ');
    sample_PR = strrep(PRs(n).PR.Sample.Sample,sprintf('\n'), ' '); 
    
    % VARIABLE GENERALIZATION
    % Variable generalization score is the difference of the sum of the generalization 
    % scores for the main variable pair between the PR and the journal
    variableGeneralization = num2str(PRs(n).PR.IV1.Generalized.Generalized + ...
        PRs(n).PR.DV1.Generalized.Generalized);
    % Create strings for independent/dependent variables in journal and PR
    variableJournal = strrep(PRs(n).Journal.IV1.IV,sprintf('\n'), ' ');
    variableJournal = strcat(variableJournal, '/');
    variableJournal = strcat(variableJournal, strrep(PRs(n).Journal.DV1.DV,sprintf('\n'), ' '));
    variablePR = strrep(PRs(n).PR.IV1.IV,sprintf('\n'), ' ');
    variablePR = strcat(variablePR, '/');
    variablePR = strcat(variablePR, strrep(PRs(n).PR.DV1.DV,sprintf('\n'), ' '));
    
    % CAUSATION EXAGGERATION
    % Causation exaggeration score is the difference between the causation score
    % which ranges from 1 (no causation) to 6 (explicit causation) between 
    % the PR and the journal
    causationPR = num2str(PRs(n).PR.Statement1.Code);
    causationJournal = num2str(PRs(n).Journal.Statement1.Code);
    causationExaggeration = num2str(PRs(n).PR.Statement1.Code - ...
        PRs(n).Journal.Statement1.Code);
    if causationPR == '0' % 0 codes for a lack of mention
        causationPR = 'Not mentioned'
    end

    if causationJournal == '0' % 0 codes for a lack of mention
        causationJournal = 'Not mentioned'
    end
   
    % ADVICE EXAGGERATION
    % Advice exaggeration score is the difference of the code between the
    % PR and the journal, which ranges from 0 (no advice) to 3 (explicit advice
    % to public)
    adviceExaggerated =  PRs(n).PR.Advice.Code-PRs(n).Journal.Advice.Code;  
    adviceJournal = PRs(n).Journal.Advice.Code;
    advicePR = PRs(n).PR.Advice.Code;
    
    % CURE
    % Was the word "cure" used in the press release, and in what context?
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

    % WRITE STRINGS TO FILE
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

% CLOSE FILE
fclose(fileID);

