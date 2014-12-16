% Copied from http://uk.mathworks.com/help/bioinfo/ug/creating-get-functions.html

function pmstruct = getpubmed(searchterm,varargin)
% GETPUBMED Search PubMed database & write results to MATLAB structure
% Error checking for required input SEARCHTERM
if(nargin<1)
    error('GETPUBMED:NotEnoughInputArguments',...
          'SEARCHTERM is missing.');
end
% Set default settings for property name/value pairs, 
% 'NUMBEROFRECORDS' and 'DATEOFPUBLICATION'
maxnum = 50; % NUMBEROFRECORDS default is 50
pubdate = ''; % DATEOFPUBLICATION default is an empty string
% Parsing the property name/value pairs 
num_argin = numel(varargin);
for n = 1:2:num_argin
    arg = varargin{n};
    switch lower(arg)
        
        % If NUMBEROFRECORDS is passed, set MAXNUM
        case 'numberofrecords'
            maxnum = varargin{n+1};
        
        % If DATEOFPUBLICATION is passed, set PUBDATE
        case 'dateofpublication'
            pubdate = varargin{n+1};          
            
    end     
end
% Create base URL for PubMed db site
baseSearchURL = 'http://www.ncbi.nlm.nih.gov/sites/entrez?cmd=search';
% Set db parameter to pubmed
dbOpt = '&db=pubmed';

% Set term parameter to SEARCHTERM and PUBDATE 
% (Default PUBDATE is '')
termOpt = ['&term=',searchterm];

% % Set report parameter to medline
reportOpt = '&report=medline';

% Set format parameter to text
formatOpt = '&format=text';

% Set dispmax to MAXNUM 
% (Default MAXNUM is 50)
maxOpt = ['&dispmax=',num2str(maxnum)];
% Create search URL
searchURL = [baseSearchURL,dbOpt,termOpt,reportOpt,formatOpt,maxOpt];
%searchURL = ['http://www.ncbi.nlm.nih.gov/pubmed?term=', searchterm];

medlineText = urlread(searchURL);
hits = regexp(medlineText,'PMID-.*?(?=PMID|</pre>$)','match');
pmstruct = struct('PubMedID','','PublicationDate','','Title','',...
             'Abstract','','Authors','','Citation','');
for n = 1:numel(hits)
    pmstruct(n).PubMedID = regexp(hits{n},'(?<=PMID- ).*?(?=\n)','match', 'once');
    pmstruct(n).PublicationDate = regexp(hits{n},'(?<=DP  - ).*?(?=\n)','match', 'once');
    pmstruct(n).Title = regexp(hits{n},'(?<=TI  - ).*?(?=PG  -|AB  -)','match', 'once');
    pmstruct(n).Abstract = regexp(hits{n},'(?<=AB  - ).*?(?=AD  -)','match', 'once');
    pmstruct(n).Authors = regexp(hits{n},'(?<=AU  - ).*?(?=\n)','match');
    pmstruct(n).Citation = regexp(hits{n},'(?<=SO  - ).*?(?=\n)','match', 'once');
end
