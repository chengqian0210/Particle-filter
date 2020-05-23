clc;
clear all;
%滤波器状态初始化
a=1.83675;b=-0.0033168;c=0.08175;d=0.01383;%初始值（将4组电池的a b c d的平均值作为模型的参数初始值）
X0=[a,b,c,d]';
L=168;  %电池数据的长度
N=200;  %粒子数
T=80;   %前80组为训练数，80组后开始预测
Uth=1.4;  %失效阈值
cita=1e-4;
wa=0.000001;wb=0.01;wc=0.1;wd=0.0001;
Q=cita*diag([wa,wb,wc,wd]);%状态噪声协方差
F=eye(4);%驱动矩阵
R=0.0001;%量测噪声协方差
Xpf=zeros(4,T);

Z=[1.8565,1.8463,1.8353,1.8353,1.8346,1.8357,1.8351,1.8258,1.8248,1.8246,1.8246,1.8142,1.8138,...
    1.8134,1.8026,1.8021,1.8026,1.8031,1.8028,1.8470,1.8474,1.8362,1.8258,1.8251,1.8256,1.8140,...
    1.8148,1.8140,1.8028,1.8041,1.8518,1.8307,1.8199,1.8093,1.8046,1.7994,1.7884,1.7829,1.7730,...
    1.7730,1.7679,1.7623,1.7676,1.7627,1.7517,1.7418,1.7361,1.7936,1.7832,1.7674,1.7570,1.7469,...
    1.7417,1.7364,1.7263,1.7158,1.7105,1.7060,1.7003,1.6946,1.6849,1.6745,1.6746,1.6637,1.6590,...
    1.6539,1.6427,1.6379,1.6327,1.6278,1.6221,1.6113,1.6066,1.6015,1.5904,1.5858,1.5849,1.5955,...
    1.5747,1.5649,1.5598,1.5595,1.5547,1.5489,1.5382,1.5279,1.5285,1.5226,1.5175,1.6058,1.5638,...
    1.5481,1.5324,1.5270,1.5170,1.5119,1.5066,1.5015,1.4908,1.4859,1.4804,1.4752,1.4859,1.4961,...
    1.4808,1.4698,1.4539,1.4541,1.4550,1.4490,1.4387,1.4334,1.4334,1.4281,1.4229,1.4174,1.4124,...
    1.4126,1.4076,1.4334,1.4383,1.4174,1.4070,1.4012,1.3967,1.3913,1.3862,1.3804,1.3752,1.3705,...
    1.3705,1.3647,1.3754,1.3861,1.3699,1.3648,1.3543,1.3546,1.3547,1.3493,1.3442,1.3390,1.3389,...
    1.3340,1.3286,1.3232,1.3182,1.3185,1.3183,1.3239,1.3601,1.3395,1.3290,1.3237,1.3186,1.3135,...
    1.3132,1.3078,1.3030,1.3034,1.3034,1.2979,1.2981,1.2935,1.2880,1.2875,1.3090,1.3251]; %B05电池数据

% Z=[2.0353,2.0251,2.0133,2.0133,2.0005,2.0139,2.0131,1.9688,1.9682,1.9572,1.9456,1.9348,1.9233,...
%     1.9119,1.9011,1.8892,1.8783,1.8676,1.8676,1.9796,1.9575,1.9458,1.9242,1.9460,1.9014,1.8787,...
%     1.8683,1.8560,1.8452,1.8572,1.9248,1.8822,1.8553,1.8393,1.8185,1.8135,1.7971,1.7810,1.7710,...
%     1.7605,1.7503,1.7395,1.7547,1.7659,1.7338,1.7133,1.7024,1.8237,1.8081,1.7758,1.7447,1.7292,...
%     1.7081,1.6976,1.6821,1.6715,1.6608,1.6511,1.6401,1.6292,1.6088,1.6035,1.5990,1.5876,1.5830,...
%     1.5671,1.5613,1.5512,1.5407,1.5253,1.5302,1.5247,1.5145,1.5094,1.5040,1.4935,1.4876,1.5303,...
%     1.5041,1.4888,1.4783,1.4785,1.4732,1.4675,1.4516,1.4519,1.4471,1.4469,1.4417,1.5936,1.5464,...
%     1.5147,1.4990,1.4831,1.4730,1.4628,1.4518,1.4469,1.4414,1.4312,1.4260,1.4205,1.4207,1.4523,...
%     1.4316,1.4150,1.4097,1.4049,1.3952,1.3945,1.3893,1.3838,1.3737,1.3786,1.3738,1.3683,1.3633,...
%     1.3581,1.3533,1.3842,1.4051,1.3787,1.3683,1.3573,1.3525,1.3474,1.3370,1.3312,1.3259,1.3216,...
%     1.3212,1.3156,1.3209,1.3474,1.3260,1.3101,1.3052,1.3004,1.3002,1.2895,1.2793,1.2792,1.2740,...
%     1.2741,1.2638,1.2581,1.2533,1.2532,1.2481,1.2534,1.2898,1.2635,1.2480,1.2321,1.2271,1.2217,...
%     1.2111,1.2056,1.2009,1.1906,1.1852,1.1797,1.1746,1.1538,1.1644,1.1588,1.1750,1.1857];%B06电池数据

% Z=[1.8911,1.8806,1.8807,1.8808,1.8795,1.8807,1.8799,1.8815,1.8697,1.8701,1.8700,1.8597,1.8591,...
%     1.8590,1.8594,1.8587,1.8478,1.8485,1.8484,1.8808,1.8815,1.8811,1.8710,1.8702,1.8707,1.8596,...
%     1.8600,1.8592,1.8481,1.8492,1.8835,1.8628,1.8521,1.8470,1.8368,1.8372,1.8317,1.8211,1.8165,...
%     1.8114,1.8116,1.8061,1.8132,1.8063,1.7958,1.7859,1.7803,1.8151,1.8157,1.8002,1.7904,1.7803,...
%     1.7753,1.7703,1.7601,1.7496,1.7497,1.7450,1.7396,1.7286,1.7239,1.7140,1.7140,1.7037,1.7040,...
%     1.6936,1.6877,1.6831,1.6779,1.6732,1.6674,1.6623,1.6574,1.6525,1.6472,1.6364,1.6363,1.6411,...
%     1.6316,1.6212,1.6164,1.6158,1.6167,1.6109,1.6007,1.5959,1.5962,1.5958,1.5907,1.6888,1.6260,...
%     1.6157,1.6057,1.5950,1.5904,1.5854,1.5800,1.5752,1.5698,1.5703,1.5652,1.5596,1.5650,1.5750,...
%     1.5653,1.5598,1.5499,1.5439,1.5450,1.5446,1.5343,1.5388,1.5289,1.5291,1.5239,1.5187,1.5136,...
%     1.5136,1.5139,1.5340,1.5391,1.5236,1.5136,1.5078,1.5032,1.4978,1.4928,1.4924,1.4875,1.4825,...
%     1.4828,1.4770,1.4819,1.4981,1.4821,1.4771,1.4721,1.4722,1.4670,1.4618,1.4567,1.4514,1.4516,...
%     1.4468,1.4468,1.4414,1.4362,1.4368,1.4363,1.4419,1.4672,1.4519,1.4471,1.4418,1.4316,1.4318,...
%     1.4263,1.4261,1.4213,1.4163,1.4166,1.4108,1.4110,1.4062,1.4063,1.4005,1.4218,1.4325];%B07电池数据

% Z=[1.8550,1.8432,1.8396,1.8307,1.8327,1.8285,1.8212,1.8152,1.8043,1.8231,1.8121,1.8047,1.7908,...
%     1.7835,1.7809,1.7712,1.7686,1.7536,1.7462,1.7377,1.7315,1.7086,1.7115,1.7075,1.7492,1.7328,...
%     1.7222,1.7118,1.6993,1.6940,1.6819,1.6770,1.6655,1.6572,1.6482,1.6388,1.6276,1.6222,1.6140,...
%     1.6761,1.6493,1.6324,1.6164,1.6109,1.5955,1.7267,1.7166,1.6958,1.6778,1.6607,1.6664,1.6468,...
%     1.6258,1.6122,1.6057,1.6736,1.6404,1.6133,1.5921,1.5866,1.5801,1.5642,1.5556,1.5402,1.5322,...
%     1.5316,1.5223,1.5065,1.5014,1.4964,1.5334,1.5238,1.5012,1.4924,1.4833,1.4807,1.4735,1.4680,...
%     1.4581,1.4479,1.4528,1.4425,1.4393,1.4286,1.4249,1.4698,1.4526,1.4428,1.4284,1.4155,1.4546,...
%     1.4283,1.4197,1.4156,1.4057,1.4084,1.3969,1.3936,1.3894,1.3786,1.3849,1.3703,1.3733,1.3679,...
%     1.3567,1.4604,1.4501,1.4381,1.4284,1.4148,1.4139,1.3989,1.3953,1.3900,1.3860,1.3882,1.3762,...
%     1.3647,1.3590,1.3462,1.4268,1.4064,1.3935,1.3882,1.3702,1.3797,1.3687,1.3627,1.3634,1.3519,1.3548,1.3411];%B18电池数据



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%更新模型参数
 %粒子集初始化
Xm=zeros(4,N,T);
Xpf(:,1)=X0;
for i=1:N
    Xm(:,i,1)=X0+sqrtm(Q)*randn(4,1);
end
 %观测量
% Z(1,1:L)=n(1:L,:)';
 %滤波器预测观测Zm与Xm对应
Zm=zeros(1,N,L);
 %滤波器滤波后Zpf与Xpf相对应

 %权值初始化
W=zeros(1,N);%W=zeros(L,N);
% Zpf=zeros(1,L-T);
%粒子滤波算法 
for k=1:T   
  %采样
    for i=1:N
        Xm(:,i,k+1)=F*Xm(:,i,k)+sqrtm(Q)*randn(4,1);
    end
 %重要性权值计算
    for i=1:N
   %量测预测
        Zm(1,i,k)=feval('hfun',Xm(:,i,k),k);
       %重要性权值
        W(k,i)=exp(-(Z(1,k)-Zm(1,i,k))^2/2/R)+1e-99;
    end
 %归一化权值
    W(k,:)=W(k,:)./sum(W(k,:));
  %重采样
    outIndex = residualR(1:N,W(k,:)');  %残差重采样      
%      %得到新的样本集
    Xm(:,:,k)=Xm(:,outIndex,k);
%  %滤波器滤波后的状态更新为：
    Xpf(:,k)=[mean(Xm(1,:,k));mean(Xm(2,:,k));mean(Xm(3,:,k));mean(Xm(4,:,k))];
    
end


%%%%%%%%%%%%%%%%%%% 寿命预测

    a_update=Xpf(1,T); b_update=Xpf(2,T); c_update=Xpf(3,T); d_update=Xpf(4,T);
    
   Xm_update=zeros(4,N,L); 
   Zm_update=zeros(1,N,L);
   Xpf_update=zeros(4,L);
   Zpf=zeros(1,L);
   X0_update=[a_update,b_update,c_update,d_update]';
   Xpf_update(:,1)=X0_update;
   for i=1:N
     Xm_update(:,i,1)=X0_update+sqrtm(Q)*randn(4,1);
   end
for k=1:L 
  %采样
    for i=1:N
        Xm_update(:,i,k+1)=F*Xm_update(:,i,k)+sqrtm(Q)*randn(4,1);
    end
     %重要性权值计算
    for i=1:N
   %量测预测
        Zm_update(1,i,k)=feval('hfun',Xm_update(:,i,k),k);
       %重要性权值
        W(k,i)=exp(-(Z(1,k)-Zm_update(1,i,k))^2/2/R)+1e-99;
    end
 %归一化权值
    W(k,:)=W(k,:)./sum(W(k,:));
  %重采样
    outIndex = residualR(1:N,W(k,:)');  %残差重采样      
%      %得到新的样本集
    Xm_update(:,:,k)=Xm_update(:,outIndex,k);
%  %滤波器滤波后的状态更新为：
    Xpf_update(:,k)=[mean(Xm_update(1,:,k));mean(Xm_update(2,:,k));mean(Xm_update(3,:,k));mean(Xm_update(4,:,k))];   
%    % 用更新后的状态计算容量
     Zpf(1,k)=feval('hfun',Xpf_update(:,k),k);
%    RRR(1,k)=feval('hfun',Zpf(1,k),k);



if Zpf(1,k)<Uth
    break;
end

end
% plot(RRR);
error=abs(Z-Zpf); %预测值与原值间的误差
% 
% HH=Z-Zpf;
% III=exp(-(error).^2/2/R)+1e-99;

Rerror=error./Z;

% for i=1:L
  A=find(Zpf>1.4);
  RUL=length(A)-T;%起始点后的预测寿命
  B=find(Z>1.4);
  Ture=length(B)-T;%起始点后的实际寿命
  RULerror=abs(RUL-Ture); %剩余寿命误差值
% end


figure(1)

plot(Z,'-b.'); %实际数据
hold on
plot(Zpf,'-r.');%滤波后的数据
hold on
plot([0,180],[Uth,Uth],'g-');
hold on
plot([T,T],[1.2,2],'k--');
% hold on
% plot(L,'k');
hold on
axis([0 180 1.2 2]);
xlabel('循环数/次');ylabel('放电容量/Ah');
legend('真实数据','预测数据','容量失效阈值','预测起始点');
figure(2)
plot(error);
axis([0 180 0 0.03]);
xlabel('循环数/次');ylabel('电池容量预测误差/Ah');
legend('容量误差值');


% figure;
% plot(III);

% RUL=zeros(1,N);
% for g=89:140
%     temp=find(Zpf(g)<1.4);
%     if(length(temp)>0)
%         RUL(g)=temp(1);
%         RUL(temp(1))=RUL(temp(1))+W(81,g);
%     end
% end

%绘制在特定的时间估计的概率密度函数
% if k==20
%     pdf=zeros(81,1);
%     for m=-40:40
%         for i=1:N
%             if(m<=Xm_update(i)&&(Xm_update(i)<m+1))   %pdf为概率密度函数，这里为Xm_update(i)值落在[m,m+1）上的次数
%                 pdf(m+41)=pdf(m+41)+1;
%             end
%         end
%     end
%     figure;
%     m=80:160;
%     plot(m,pdf/N,'r');
%     hold;
%     title('estimated pdf at k=20');
% end
% for i=1:N
%     plot(Xpf(i),W(i));
% end
pdf=zeros(168,200);
for m=0.01:0.01:2   
    for i=1:168
        for k=1:200
            if(m<=Zm_update(:,k,i)&&(Zm_update(:,k,i)<(m+0.01)))   %pdf为概率密度函数，这里为Xm_update(i)值落在[m,m+1）上的次数
                M = (100*m - 1)/10+1;
                M = int32(M);
                pdf(i,M) = pdf(i,M) + 1;
            end
        end
    end
end

%sumpdf_ =(sum((pdf))/168)/200;

figure;
m=0.01:0.01:2;
plot(m,pdf/200,'r');
hold;
title('estimated pdf at k=20');

    pdf=zeros(200,200);
    for m=0.01:0.01:2
        for k=1:200
        for i=1:168
            if(m<=Zm_update(:,k,i)&&(Zm_update(:,k,i)<(m+0.01)))   %pdf为概率密度函数，这里为Xm_update(i)值落在[m,m+1）上的次数
                M = (100*m - 1)/10+1;
                M = int32(M);
                pdf(k,M) = pdf(k,M) + 1;
            end
        end
        end
    end
    %sumpdf =sum(pdf)/200/168;    
    figure;
    m=0.01:0.01:2;
    plot(m,pdf/168,'r');
    hold;
    title('estimated pdf at k=20');
    
    sumpdf =sum(pdf)/200/168;
    figure;
    m=0.01:0.01:2;
    plot(m,sumpdf,'r');
    hold;
    title('estimated pdf at k=20');
    
    
            figure;
    newstart = zeros(1,200);
    for m=0.01:0.01:2
        pop = int32((10*m - 0.1)+1);
        %%yy(pop) = nfun(Xpf_update(1,80),Xpf_update(2,80),Xpf_update(3,80),Xpf_update(4,80),m);%%容量与剩余循环次数对应关系         
        yy(pop) = 131 - 10*m;%%自己求求看，我搞不出来了
        g(pop) = sumpdf(1,pop)+1.4;        
    end
    plot(yy,g);
    
    figure
plot(yy,g);
hold on
plot(Z,'-b.'); %实际数据
hold on
plot(Zpf,'-r.');%滤波后的数据
hold on
plot([0,180],[Uth,Uth],'g-');
hold on
plot([T,T],[1.2,2],'k--');
% hold on
% plot(L,'k');
hold on
axis([0 180 1.2 2]);
xlabel('循环数/次');ylabel('放电容量/Ah');
legend('真实数据','预测数据','容量失效阈值','预测起始点');

    
    
%     figure;
%     m=1:0.01:2;
%     plot(sumpdf,m,'r');
%     hold;