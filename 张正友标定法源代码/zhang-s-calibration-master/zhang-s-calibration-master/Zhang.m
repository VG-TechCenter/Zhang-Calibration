
function [k1,k2,A]=Zhang(M,m)

    [~,npts]=size(M);
    matrixone=ones(1,npts);
    M=[M;matrixone];%%ת��Ϊ�������
    num=size(m,3);%%��Ƭ����
    for i=1:num
        m(3,:,i)=matrixone; 
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%���Ƶ�Ӧ�Ծ���H,�ο�ԭ�ĸ�¼A
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for i=1:num
        H(:,:,i)=homography2d(M,m(:,:,i))';
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%��������ڲ�������A,�ο�ԭ��3.1�ں͸�¼B
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    V=[];
    for flag=1:num
        v12(:,:,flag)=[H(1,1,flag)*H(2,1,flag), H(1,1,flag)*H(2,2,flag)+H(1,2,flag)*H(2,1,flag), H(1,2,flag)*H(2,2,flag), H(1,3,flag)*H(2,1,flag)+H(1,1,flag)*H(2,3,flag), H(1,3,flag)*H(2,2,flag)+H(1,2,flag)*H(2,3,flag), H(1,3,flag)*H(2,3,flag)];
        v11(:,:,flag)=[H(1,1,flag)*H(1,1,flag), H(1,1,flag)*H(1,2,flag)+H(1,2,flag)*H(1,1,flag), H(1,2,flag)*H(1,2,flag), H(1,3,flag)*H(1,1,flag)+H(1,1,flag)*H(1,3,flag), H(1,3,flag)*H(1,2,flag)+H(1,2,flag)*H(1,3,flag), H(1,3,flag)*H(1,3,flag)];
        v22(:,:,flag)=[H(2,1,flag)*H(2,1,flag), H(2,1,flag)*H(2,2,flag)+H(2,2,flag)*H(2,1,flag), H(2,2,flag)*H(2,2,flag), H(2,3,flag)*H(2,1,flag)+H(2,1,flag)*H(2,3,flag), H(2,3,flag)*H(2,2,flag)+H(2,2,flag)*H(2,3,flag), H(2,3,flag)*H(2,3,flag)];
        V=[V;v12(:,:,flag);v11(:,:,flag)-v22(:,:,flag)];
    end
    k=V'*V;      
    [~,~,d]=svd(k);
    b=d(:,6);%Vb=0����С���˽�
    v0=(b(2)*b(4)-b(1)*b(5))/(b(1)*b(3)-b(2)^2);
    s=b(6)-(b(4)^2+v0*(b(2)*b(4)-b(1)*b(5)))/b(1);
    alpha_u=sqrt(s/b(1));
    alpha_v=sqrt(s*b(1)/(b(1)*b(3)-b(2)^2));
    skewness=-b(2)*alpha_u*alpha_u*alpha_v/s;
    u0=skewness*v0/alpha_u-b(4)*alpha_u*alpha_u/s;
    A=[alpha_u skewness u0
        0      alpha_v  v0
        0      0        1];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%�����������ϵ��k1,k2,���Ż����в���
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    D=[];
    d=[];
    Rm=[];
    for flag=1:num
        %���Ƴ߶����ӣ��ο�3.1��
        s=(1/norm(A\H(1,:,flag)')+1/norm(A\H(2,:,flag)'))/2;
        rl1=s*(A\H(1,:,flag)');%ע������
        rl2=s*(A\H(2,:,flag)');
        rl3=cross(rl1,rl2);   
        RL=[rl1,rl2,rl3];
        %������ת����,�ο���¼C
        [U,~,V] = svd(RL);
        RL=U*V';
        TL=s*(A\H(3,:,flag)');
        RT=[rl1,rl2,TL];
        XY=RT*M;
        UV=A*XY;
        UV=[UV(1,:)./UV(3,:); UV(2,:)./UV(3,:); UV(3,:)./UV(3,:)];
        XY=[XY(1,:)./XY(3,:); XY(2,:)./XY(3,:); XY(3,:)./XY(3,:)];
        for j=1:npts
            D=[D; ((UV(1,j)-u0)*( (XY(1,j))^2 + (XY(2,j))^2 )) , ((UV(1,j)-u0)*( (XY(1,j))^2 + (XY(2,j))^2 )^2) ; ((UV(2,j)-v0)*( (XY(1,j))^2 + (XY(2,j))^2 )) , ((UV(2,j)-v0)*( (XY(1,j))^2 + (XY(2,j))^2 )^2) ];
            d=[d; (m(1,j,flag)-UV(1,j)) ; (m(2,j,flag)-UV(2,j))];
        end
        r13=RL(1,3);
        r12=RL(1,2);
        r23=RL(2,3);
        Q1=-asin(r13);
        Q2=asin(r12/cos(Q1));
        Q3=asin(r23/cos(Q1));
        R_new=[Q1,Q2,Q3,TL'];
        Rm=[Rm , R_new];
    end
% ����k1,k2 �ο���ʽ13
    k=(D'*D)\D'*d;
% �����Ȼ���� �ο���ʽ14
    para=[Rm,k(1),k(2),alpha_u,skewness,u0,alpha_v,v0];
    options = optimset('Algorithm', 'levenberg-marquardt');
    [x,~,~,~,~]  = lsqnonlin( @simon_HHH, para, [],[],options, m, M);
    k1=x(num*6+1);
    k2=x(num*6+2) ;
    A=[x(num*6+3) x(num*6+4) x(num*6+5); 0 x(num*6+6) x(num*6+7); 0,0,1];
end




