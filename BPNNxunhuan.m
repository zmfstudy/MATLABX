% 模型一
% 不加入RR间期特征
clear all
clc
% 加载数据
% load('S:\二次实验\所有NV\train_Data.csv');
load('S:\三次实验\train_Data_200.csv');

% x_train = train_Data;
x_train = train_Data_200;
X11=x_train(1:5000,2:204);   % 干扰波形5000
X11=X11';
X22=x_train(5001:10000,2:204);  % 室早波形5000
X22=X22';


X111=X11(:,1:4000);     % N取4000做训练
X112=X11(:,4001:5000);  % N取1000做测试


X221=X22(:,1:4000);     % V取4000做训练
X222=X22(:,4001:5000);  % V取1000做测试


X=[X111 X221];    % 训练集:一列为一个样本
XAA = X;
XX=[X112 X222] ;  % 测试集:一列为一个样本

% 建立训练集标签 00 01
y1=zeros(2,8000);
for i=4001:8000
    y1(2,i)=1;
end



FlattenedData = X(:)'; % 展开矩阵为一列，然后转置为一行。
MappedFlattened = mapminmax(FlattenedData, 0, 1); % 归一化。
X = reshape(MappedFlattened, size(X)); % 还原为原始矩阵形式。此处不需转置回去，因为reshape恰好是按列重新排序
% 定义三个参数
hidden = [20,21,22,23,24,25,26,27,28,29];
% hidden = [26,27,28,29];
error_train = [1e-4,2e-4,3e-4,4e-4,5e-4,6e-4,7e-4,8e-4,9e-4,1e-3];
yuzhi = [0.4,0.5,0.6,0.7];
jishu = 1;

for ii=9:9
    for jj=4:10
        for kkk=1:4
             % 设置随机种子
            setdemorandstream(pi)
            %%%%%%%%%%%%%%%%%%%%%
            %%%% 建立神经网络 %%%%
            %%%%%%%%%%%%%%%%%%%%%
            net=newff(minmax(X),[hidden(ii),2],{'tansig','purelin'},'trainlm');
            net.trainParam.show=10; %设置数据显示刷新频率，学习次刷新一次图象
            net.trainParam.epochs=100; %最大 训练次数
            
            net.trainParam.goal=error_train(jj); % 设置训练误差
            net=init(net);%网络初始化
            [net, tr]=train(net,X,y1);%训练网络
%             disp('BP神经网络训练完成！');
            
            FlattenedData1 = XX(:)'; % 展开矩阵为一列，然后转置为一行。
            MappedFlattened1 = mapminmax(FlattenedData1, 0, 1); % 归一化。
            XX = reshape(MappedFlattened1, size(XX)); % 还原为原始矩阵形式。此处不需转置回去，因为reshape恰好是按列重新排序
            
            result_test1 = sim(net,XX);%测试样本仿真
            result_test = result_test1;
            
            result_test( result_test>yuzhi(kkk))=1;
            result_test( result_test<=yuzhi(kkk))=0;
%             disp('网络输出:')
            result_test;
            jieguo = result_test';
            
            t1=zeros(1,1000);
            t2=ones(1,1000);
            
            pp_lab=[t1 t2]; % 测试样本标签（正确类别）
            res = vec2ind(result_test)-1; % 向量值变索引值
            strr = cell(1,2000);
            kk=0;
            for i=1:2000
                if res(i) == pp_lab(i)
                    strr{i} = '0'; % 测试 = 标签
                    kk=kk+1;
                else
                    strr{i} = '1'; % 测试 != 标签
                end
            end
            result = strr';            
            acc(jishu)=kk/size(pp_lab,2);
            hidden_res(jishu) = hidden(ii)
            error_train_res(jishu) = error_train(jj)
            yuzhi_res(jishu) = yuzhi(kkk)
            ii_res(jishu) = ii;
            jj_res(jishu) = jj;
            kkk_res(jishu) = kkk;
            acc = acc';
            hidden_res = hidden_res';
            error_train_res = error_train_res';
            yuzhi_res = yuzhi_res';
            jishu = jishu + 1;
        end
    end
end
% plotconfusion(pp_lab, res);
% disp('预测完成！');
