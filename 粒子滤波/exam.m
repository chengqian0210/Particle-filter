clc;
clear all;
x = 0.1; % initial state
Q = 1; % process noise covariance
R = 1; % measurement noise covariance
tf = 50; % simulation length
N = 100; % number of particles in the particle filter
xhat = x;
P = 2;
xhatPart = x;
% Initialize the particle filter. 初始化粒子滤波， xpart 值用来在不同时刻生成粒子
for i = 1 : N
    xpart(i) = x + sqrt(P) * randn;
end
xArr = [x];
xhatPartArr = [xhatPart];
for k = 1 : tf %tf 为时间长度， k 可以理解为时间轴上的k 时刻
    % System simulation
    % x 数据为时刻k 的真实状态值
    x = 0.5 * x + 25 * x / (1 + x^2) + 8 * cos(1.2*(k-1)) + sqrt(Q) * randn; % 状态方程(1)
    y = x^2 / 20 + sqrt(R) * randn;% 观测方程(2)
    % Particle filter 生成100 个粒子并根据预测和观测值差值计算各个粒子的权重
    for i = 1 : N
        xpartminus(i) = 0.5 * xpart(i) + 25 * xpart(i) / (1 + xpart(i)^2) + 8 * cos(1.2*(k-1)) + sqrt(Q) * randn;
        ypart = xpartminus(i)^2 / 20;
        vhat = y - ypart; % 观测和预测的差
        q(i) = (1 / sqrt(R) / sqrt(2*pi)) * exp(-vhat^2 / 2 / R); % 根据差值给出权重
    end
    % Normalize the likelihood of each a priori estimate.
    qsum = sum(q);
    for i = 1 : N
        q(i) = q(i) / qsum;% 归一化权重
    end
    % Resample.
    for i = 1 : N
        u = rand; % uniform random number between 0 and 1
        qtempsum = 0;
        for j = 1 : N
            qtempsum = qtempsum + q(j);
            if qtempsum >= u
                %重采样对低权重进行剔除， 同时保留高权重， 防止退化的办法
                xpart(i) = xpartminus(j);
                break;
            end
        end
    end
    % The particle filter estimate is the mean of the particles.
    xhatPart = mean(xpart); %经过粒子滤波处理后的均值
    % Plot the estimated pdf's at a specific time.
    if k == 30
        % Particle filter pdf
        pdf = zeros(81,1);
        for m = -40 : 40
            for i = 1 : N
                if (m <= xpart(i)) && (xpart(i) < m+1)
                    %pdf 为概率密度函数， 这里是xpart(i) 值落在[m,m+1) 上的次数
                    pdf(m+41) = pdf(m+41) + 1;
                end
            end
        end
        figure;
        m = -40 : 40;
        %此图1 绘制k==20 时刻xpart(i) 区间分布密度
        plot(m, pdf / N, 'r');
        hold;
        title('Estimated pdf at k=20');
        disp(['min, max xpart(i) at k = 20: ', num2str(min(xpart)), ', ',num2str(max(xpart))]);
    end
    % Save data in arrays for later plotting
    xArr = [xArr x];
    xhatPartArr = [xhatPartArr xhatPart];
end
t = 0 : tf;
figure;
plot(t, xArr, 'b.', t, xhatPartArr, 'g'); %此图2 对应xArr 为真值， xhatPartArr 为粒子滤波值
xlabel('time step'); ylabel('state');
legend('True state', 'Particle filter estimate');