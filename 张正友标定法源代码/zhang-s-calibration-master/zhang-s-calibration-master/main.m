imgcount = 5;%��Ҫ�����ͼƬ����
squareSize = 0.031;
imageFileNames = {1,imgcount};
for i = 1:imgcount
  imageFileNames{i} = sprintf('images/%d.jpg', i);
end
[imagePoints,boardSize,imagesUsed] = detectCheckerboardPoints(imageFileNames);
m=permute(imagePoints,[2 1 3]);
M = generateCheckerboardPoints(boardSize,squareSize)';
%M�����̸�ǵ���������ϵ����
%m��5��ͼƬ�е����̸�ǵ�ͼ������ϵ����
[k1,k2,A]=Zhang(M,m);
k1,k2,A