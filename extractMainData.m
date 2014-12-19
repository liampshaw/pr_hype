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
headerString = ['Reference\tUniversity (press office responsible for PR)\t',...
    'JournalTitle\tAuthors (automatically downloaded from PubMed after searching with JournalTitle)\tSingle PubMed result?\t',...
    'PRTitle\tSample_changed (0=no, 1=minor, 2=major)\tSample_journal\tSample_PR\t',...
    'Advice_exaggeration (-3=stronger advice in journal, +3=stronger advice in PR)\tAdvice_journal (0=none, 3=explicit to public)\tAdvice_PR (0=none, 3=explicit to public)\t',...
    'Causation_exaggeration (Causation_PR - Causation_Journal)\tCausation_journal (0=not mentioned, 1=explicitly no causation, 6=explicitly causation)\t,'...
    'Causation_PR  (0=not mentioned, 1=explicitly no causation, 6=explicitly causation)\tVariables_generalization (0=no generalization, 4=both independent/dependent majorly generalized)\t',...
    'Variables_journal (independent/dependent)\tVariables_PR (independent/dependent)\tCure\n'];
fprintf(fileID, headerString);

% Loop through the data and extract the information
for n=1:462,
    %disp(n) % to display progress
    
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
    singlePubMedResult = 0; % Bool to indicate whether only one PubMed result returned
    search_term = lower(journalTitle);
    pubmed_data_not_title = vertcat(getpubmed(strrep(search_term, ' ', '%20')));
    if size(pubmed_data_not_title) == [1 1]
        singlePubMedResult = 1;
        if isempty(pubmed_data_not_title.Authors) == 0
            authors = strjoin(pubmed_data_not_title.Authors, ',');
        else
            %search_term = strrep(journalTitle,sprintf(' '), '%5BTitle%5D+AND+');
            %search_term = strcat(search_term, '%5BTitle%5D');
            %pubmed_data = vertcat(getpubmed(formatTitleForPubMed(journalTitle)));
            disp(n)
            authors = '--no PubMed data found--';
            disp(search_term)
        end
    else
        search_term = formatTitleForPubMed(journalTitle);
        pubmed_data = vertcat(getpubmed(search_term));
        if size(pubmed_data) == [1 1]
            if isempty(pubmed_data.Authors) == 0
                authors = strjoin(pubmed_data.Authors, ',');
            else
                %search_term = strrep(journalTitle,sprintf(' '), '%5BTitle%5D+AND+');
                %search_term = strcat(search_term, '%5BTitle%5D');
                %pubmed_data = vertcat(getpubmed(formatTitleForPubMed(journalTitle)));                
                authors = strjoin(pubmed_data_not_title(1).Authors, ',');
            end
        end
    end
    
    % SAMPLE GENERALIZATION
    % Did the sample change from journal to PR
    sampleChanged = PRs(n).PR.Sample.SameAsAbstract;
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
        causationPR = 'Not mentioned';
    end

    if causationJournal == '0' % 0 codes for a lack of mention
        causationJournal = 'Not mentioned';
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
    fprintf(fileID,['%s\t%s\t%s\t',...
    '%s\t%d\t%s\t',...
    '%d\t%d: %s\t%d: %s\t',...
    '%d\t%d\t%d\t',...
    '%s\t%s\t%s\t',...
    '%s\t%s\t%s\t',...
    '%s\n'], ...
        reference, university, journalTitle,...
        authors, singlePubMedResult, PRTitle, ...       
        sampleChanged, PRs(n).Journal.Sample.Code, sample_Journal, PRs(n).PR.Sample.Code, sample_PR,...
        adviceExaggerated, adviceJournal, advicePR, ...
        causationExaggeration, causationJournal, causationPR,...
        variableGeneralization, variableJournal, variablePR,...
        cureString);
        
end

% CLOSE FILE
fclose(fileID);

