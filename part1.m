close all;
clear all;
load('ooo.dat')
%x = full(spconvert(ooo));
x = spconvert(ooo);
size(x)
ooowords = textread('ooowords','%s');

xrs = sum(x, 2);
xcs = sum(x, 1);

[xrss, xrsi] = sort(xrs, 'descend');
[xcss, xcsi] = sort(xcs, 'descend');
xcss = full(xcss);


%-----------------
%  Frequency
%-----------------
plot(xrs);
title('Number of Words Used in Image Descriptions');
xlabel('Image Number')
ylabel('Number of Words (Classifiers)');

figure;
semilogy(xrss);
title('Number of Words Used in Image Descriptions');
xlabel('Images');
ylabel('Number of Words');
axis([0 length(xrss) 1 100]);

figure;
[h, stats] = cdfplot(xrs);
axis([0 80 0 1]);
xlabel('Number of Words in Description');
title('Empirical CDF - Number of Words in Description');

figure;
plot(xcs);
title('Word Frequency');
xlabel('Word Index');
ylabel('Word Count');

%figure;
%plot(xcss);

%------------------
%  Sorted X
%------------------
xp = x(xrsi, xcsi);
size(xp)
full(xp(1:20, 1:20))

%------------------
%  Similar Images
%------------------
xxp = xp(1:1000,:);
xprs = sum(xp, 2);
xxp = xxp*xxp';
d = tril(xxp, -1);
[i,j,v] = find(d);
vals = zeros(20,3);
distv = [];
for ii=1:length(i)
  d(i(ii),j(ii)) = d(i(ii),j(ii)) / max([4 xprs(i(ii)) xprs(j(ii))]);
  if (d(i(ii),j(ii)) > min(vals(:,3)))
    [v, indx] = min(vals(:,3));
    %i(ii)
    %j(ii)
    %ii/length(i)
    vals(indx,1) = xrsi(i(ii));
    vals(indx,2) = xrsi(j(ii));
    vals(indx,3) = d(i(ii), j(ii));
    distv = [distv vals(indx,3)];
  end
end
figure;
plot(distv);
xlabel('Iteration');
ylabel('Percent Similar');
title('Finding Similar Descriptions');
vals

%  ./similar.csh  47470          32
%  ./similar.csh  42619       23973 

%------------------
%  Latent Semantic
%  PCA Analysis
%------------------

xpp = full(xp(1:3000, 1:3000));

[coeff, scores, latent] = pca(xpp);

wid=[];
for nc=1:25
  twid=[];
  words = [];
  [c, ci] = sort(coeff(:,nc),'descend');
  for i=20:-1:1
    i1 = xcsi(ci(i));
    i2 = xcsi(ci(length(ci)-i+1));
    twid = [i1 twid i2];
    words = [ooowords(i1) c(i) xcss(ci(i)); words; ooowords(i2) c(length(ci) - i + 1) xcss(ci(length(ci) - i + 1))];
  end
  [nr, nc] = size(words);
  up1 = 1:nr/2;
  dn1 = nr:-1:nr/2+1;
  words = [words(up1,1) words(up1,2) words(up1, 3) words(dn1,1) words(dn1,2) words(dn1, 3)]
end

%  Find Top Principal Components
pcawords = [];
for nc=1:100
  [c, ci] = sort(coeff(:,nc),'descend');
  pcawords = [pcawords ooowords(xcsi(ci(1)))];
end
pcawords

%  Plot projection onto three, lets say art, military
%for i=1:4
  %for j=i:i+2
    %subplot(4, 3, (i-1)*3+j-i+1);
    %pcap('military', 'art', ooowords, xcsi, xpp, scores, i, j)
  %end
%end
figure;
pcasingle('army', ooowords, xcsi, xpp, scores, 7, 7);
figure;
pcasingle('art', ooowords, xcsi, xpp, scores, 10, 10);
figure;
pcaplot('army', 'art', ooowords, xcsi, xpp, scores, 7, 10)


%  Build String Indexes
classes = {'architecture', 'nature', 'art', 'food', 'dog', 'bike', 'bird', 'car', 'wedding', 'park', 'city', 'beach', 'army', 'music', 'church', 'flower', 'water', 'military', ...
	'people', 'national', 'world', 'travel', 'street', 'party', 'california', 'japan', 'river', 'lake', 'museum', 'collection', 'school', 'island', 'garden', 'concert'}
% Class Word Index
wci = [];
for c=classes
  wci = [wci strmatch(c, ooowords, 'exact')];
end
xc = x(:, wci);        
wc = xc'*xc;
d = full(tril(wc, -1) + triu(wc, 1));
maxd = max(max(d));
dist = ones(size(d)) * 2 * maxd - d - diag(ones(length(d),1)*2*maxd);
scaled=cmdscale(dist);

%figure;
%plot(-y(:,1), y(:,2), 'o')
%text(-y(:,1), y(:,2), classes)
%title('Description Classes Using Classical Multi-Dimensional Scaling');
scaledx = scaled(:,1);
scaledy = scaled(:,2);
figure;
plot(scaledx, scaledy, 'o');
text(scaledx, scaledy, classes);
title('Description Classes Using Classical Multi-Dimensional Scaling');
axis([min(scaledx)-20 max(scaledx)+20 min(scaledy)-20 max(scaledy)+20]);
%maxdistance([scaledx, scaledy], 3)

figure;
kmeansplot([scaledx, scaledy], classes, 8);
title('Description Classes Using Classical Multi-Dimensional Scaling');

%------------------
%  Similar Images
%------------------
xxp = xc(1:25000,:);
xxp = xxp*xxp';
d = tril(xxp, -1);
[i,j,v] = find(d);
vals = zeros(20,3);
for ii=1:length(i)
  d(i(ii),j(ii)) = d(i(ii),j(ii)) / max([4 xrs(i(ii)) xrs(j(ii))]);
  if (d(i(ii),j(ii)) > min(vals(:,3)))
    [v, indx] = min(vals(:,3));
    %i(ii)
    %j(ii)
    vals(indx,1) = i(ii);
    vals(indx,2) = j(ii);
    vals(indx,3) = d(i(ii), j(ii));
  end
end
uint32(vals)


%  -----------------------------
%  Prune and show classifiers
%  -----------------------------
C = {'park', 'water', 'bird', 'car', 'food', 'art', 'army', 'music'};
figure;
plot(scaledx, scaledy, 'o');
title('Description Classes Using Classical Multi-Dimensional Scaling');
axis([min(scaledx)-20 max(scaledx)+20 min(scaledy)-20 max(scaledy)+20]);
wci = [];
for c=C
  wci = [wci strmatch(c, classes, 'exact')];
end
hold on;
plot(scaledx(wci), scaledy(wci), '.r','markersize',30)
text(scaledx, scaledy, classes);



%-------------------------------------
%  Build our final classifier index
%-------------------------------------
wci = [];
for c=C
  wci = [wci strmatch(c, ooowords, 'exact')];
end
xc = x(:, wci);

%-------------------------------------
%  Show classes and cross probabilities
%-------------------------------------
full(xc'*xc ./ 100000)
C
classes
 
