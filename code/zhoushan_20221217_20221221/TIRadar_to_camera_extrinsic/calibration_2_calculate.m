%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%���ܣ�ʵ�����ϱ궨
%���룺
% points:�궨���ݾ��� N��5����NΪ��������������20��������ÿ��������ǰ��������ʾ�״�����[x,y,z]��float��������������ʾ��Ӧ��ͼ�������[xp,yp]��uint16��;
% A:�ڲξ��� 3��3����double float��
% B:��ξ��� 3��4����float��
%�����
% H:ͶӰ���� 3��4����double float��
%��غ�����
%psolution(alpha,fk,Jfk,Dk)��psolution(lambda,f,Jf,D)��p����С���˽�
%dphi = dphisolution(lambda,f,Jf,D)����dphi/dlambda
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%��ʼ��
clearvars;close all;clc;
addpath('./3rdpart');

camera = 'IRayCamera';
% camera = 'LeopardCamera0';
% camera = 'LeopardCamera1';

res_path = fullfile('./', strcat('res_', camera, '.mat'));

radar_points_path = 'TIRadar.xlsx';

%%
% ��ξ���������
x=[sym('thetax');sym('thetay');sym('thetaz');sym('tx');sym('ty');sym('tz')]; %���庯������ x����6��������x(1)~x(6)��double float��

% ��γ�ֵ�����úܹؼ���Ӱ�����Ƿ�����������
xk=[-pi/2;0;0;0;0;0];

% ������ξ���B
Rx=[1,0,0;0,cos(x(1)),sin(x(1));0,-sin(x(1)),cos(x(1))];
Ry=[cos(x(2)),0,-sin(x(2));0,1,0;sin(x(2)),0,cos(x(2))];
Rz=[cos(x(3)),sin(x(3)),0;-sin(x(3)),cos(x(3)),0;0,0,1];
B=[Rx*Ry*Rz,[x(4);x(5);x(6)]];

% �ڲξ���
camera_instrinsic_path = fullfile('../camera_intrinsic', strcat(camera, '.mat'));
camera_instrinsic = load(camera_instrinsic_path);
camera_instrinsic = camera_instrinsic.cameraParams;
A = camera_instrinsic.K;

%% ����������
points_xyz = readmatrix(radar_points_path, "Range", [1 1]);
mask_xyz = sum(points_xyz, 2) ~= 0;

res = load(res_path);
points_pixel = res.points_pixel;
mask_pixel = sum(points_pixel, 2) ~= 0;

points = [points_xyz, points_pixel];
points = points(mask_xyz & mask_pixel, :);

%% ������ξ���
N = size(points,1);%��ȡ���ݳ��ȣ�uint8��
H = A*B;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%�Ż���������
f = [];
for i=1:N%�����Ż���������
    Z=H*[points(i,1); points(i,2); points(i,3); 1];    
    
    f=[f; points(i,4)-Z(1)/Z(3);points(i,5)-Z(2)/Z(3)];    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%L-M�㷨���֣����������Ż����⣬�Ż�����x��
Jf=jacobian(f);%���㺯���ſɱȾ���double float��
%��ʼ��
xk_ini=xk;%�Ż���������ֵ��double float��
fk=double(subs(f,x,xk));%f������ֵ��double float��
Jfk=double(subs(Jf,x,xk));%Jf������ֵ��double float��
Dk=sqrt(diag(diag(Jfk'*Jfk)));%Dk����ֵ��double float��
sigma=0.1;%sigma�������ã�float��
pk=1;%Pk����ֵ��double float��
deltak=0.1;%��������ֵ��float��
i=0;%ѭ��������uint16��
%loop
% while norm(pk)>0.1 %��һ�Ż���ֵ 
while i<200 %��ѭ������Ϊ�Ż���ֵ���Ż���ֵ���á�
    i=i+1%ѭ������ 
    %step a,����lambda��ţ�ٷ�Ȩ�ز���
    Jfkpinv=pinv(Jfk);%��α�棨double float��
    if norm(Dk*pinv(Jfk)*fk)<=(1+sigma)*deltak%�ж��½��ݶ�
        %�ݶ�ƽ�ȣ����Խ���
        lambdak=0;%��double float��
        pk=-pinv(Jfk)*fk;%�仯��pk��double float��
    else
        %�ݶȹ�����ţ�ٷ����
        alpha=0;%lambda�Ż���ֵ��double float��
        u=norm((Jfk*inv(Dk))'*fk)/deltak;%��ȷ����㣨double float��
        palpha=psolution(alpha,fk,Jfk,Dk);%p_alpha����(double float��
        qalpha=Dk*palpha;%q_alpha����(double float��
        phi=norm(qalpha)-deltak;%phi����(double float��
        dphi = dphisolution(alpha,fk,Jfk,Dk);%dphi/dlambda����(double float��
        l=-phi/dphi;%��ȷ�����(double float��
        j=0;%ѭ����ʼ����uint16��
        while (abs(phi)>sigma*deltak)&&(j<100)%lambda�Ż�ѭ��
            j=j+1;%ѭ������
            if alpha<=l||alpha>=u%�ж��Ƿ񳬹�ȡֵ��Χ
                alpha=(0.001*u>sqrt(l*u))*0.001*u+(0.001*u<=sqrt(l*u))*sqrt(l*u);%����ʱ���Ż�����alpha���е���
            end
            if phi<0%�ж��Ƿ��½�����
                u=alpha;%��ȷ�����
            end
            l=l*(l>(alpha-phi/dphi))+(alpha-phi/dphi)*(l<=(alpha-phi/dphi));%��ȷ�����
            alpha=alpha-(phi+deltak)/deltak*phi/dphi;%alpha����
            palpha=psolution(alpha,fk,Jfk,Dk);%p_alpha����
            qalpha=Dk*palpha;%q_alpha����
            phi=norm(qalpha)-deltak;%phi����
            dphi=dphisolution(alpha,fk,Jfk,Dk);%dphi/dlambda����
        end
        lambdak=alpha;%�Ż���ɣ�lambda��ֵ
        pk = psolution(lambdak,fk,Jfk,Dk);%pk����
    end
    %step b���������������Զȼ���
    fkp=double(subs(f,x,xk+pk));%�仯���Ż�����ȡֵ(double float��
    fkkp(:,i)=fkp'*fkp;
    rhok=((fk'*fk)-fkp'*fkp)/(fk'*fk-(fk+Jfk*pk)'*(fk+Jfk*pk)) ;%���Զȼ���(double float��
    %step c���Ż���������
    if rhok>0.0001%���ԶȺ���
        xk=xk+pk;%�Ż���������
        fk=double(subs(f,x,xk));%fk����
        Jfk=double(subs(Jf,x,xk)); %Jfk����
    end
    %step d����������
    if rhok<=0.25%���Զȹ�С��˵����������
        deltak=0.5*deltak;%������С����
    elseif (rhok>0.25&&rhok<0.75&&lambdak==0)||rhok>=0.75%���Զȹ���˵��������С
        deltak=2*norm(Dk*pk);%�����������
    end
    %step e�����²����ݶ�
    Dk=(Dk>sqrt(diag(diag(Jfk'*Jfk)))).*Dk+(Dk<=sqrt(diag(diag(Jfk'*Jfk)))).*sqrt(diag(diag(Jfk'*Jfk)));%����Dk
    xkk(:,i)=xk;%�Ż������������洢��12��I����IΪ�Ż�ѭ������ĿǰΪ1000����
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%��ͼ����
xkk_ini=xk_ini*ones(1,size(xkk,2));%�������ȼ��������þ����㣨12��I����double float��
y=diag(sqrt((xkk-xkk_ini)'*(xkk-xkk_ini)));%�������ȼ��㣬������double float��
plot(y)%��ͼ
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% �����洢

% ͶӰ����3��4����double float��
Hx=double(subs(H,x,xk));

% ��ξ���
Bx=A\Hx;

res = load(res_path);
res.points_pixel = points_pixel;
res.points_xyz = points_xyz;
res.points = points;
res.Hx = Hx;
res.Bx = Bx;

cmd = 'save(res_path';
fns = fieldnames(res);
for i = 1:length(fns)
    cmd = strcat(cmd, sprintf(', "%s"', fns{i}));
end
cmd = strcat(cmd, ');');
eval(cmd);


