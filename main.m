%自己编写优秀种群生成函数initpop 和 适应度函数calobjvalue



clc,clear,close all;
warning off
global popsize length min max N code;
N=12;                % 每个染色体段数（十进制编码位数）
M=100;               % 进化代数
popsize=30;          % 设置初始参数，群体大小
length=10;           % length为每段基因的二进制编码位数
chromlength=N*length;  % 字符串长度（个体长度），染色体的二进制编码长度
pc=0.7;                % 设置交叉概率，本例中交叉概率是定值，若想设置变化的交叉概率可用表达式表示，或从写一个交叉概率函数，例如用神经网络训练得到的值作为交叉概率
pm=0.3;                % 设置变异概率，同理也可设置为变化的
bound={-100*ones(popsize,1),zeros(popsize,1)};
min=bound{1};max=bound{2};
pop=initpop(popsize,chromlength);                     %运行初始化函数，随机产生初始群体
ymax=500;   % 适应度值初始化

ysw_x = zeros(3,12);
% 故障类型编码，每一行为一种！code(1,:)，正常；code(2,:)，50％；code(3,:)，150％
code =[-0.8180   -1.6201  -14.8590  -17.9706  -24.0737  -33.4498  -43.3949  -53.3849  -63.3451  -73.0295  -79.6806  -74.3230
       -0.7791   -1.2697  -14.8682  -26.2274  -30.2779  -39.4852  -49.4172  -59.4058  -69.3676  -79.0657  -85.8789  -81.0905
       -0.8571   -1.9871  -13.4385  -13.8463  -20.4918  -29.9230  -39.8724  -49.8629  -59.8215  -69.4926  -75.9868  -70.6706];

for i=1:3   % 3种故障模式，每种模式应该产生 popsize 种监测器（抗体），每种监测器的长度和故障编码的长度相同
    pop=initpop(popsize,chromlength);                     %运行初始化函数，随机产生初始群体
    for k=1:M
       [objvalue]=calobjvalue(pop,i);                 %计算目标函数
       fitvalue=calfitvalue(objvalue); favg(k)=sum(fitvalue)/popsize;  %计算群体中每个个体的适应度
       newpop=selection(pop,fitvalue); objvalue=calobjvalue(newpop,i); %选择
       newpop=crossover(newpop,pc,k);  objvalue=calobjvalue(newpop,i); %交叉
       newpop=mutation(newpop,pm);     objvalue=calobjvalue(newpop,i); %变异
       [bestindividual,bestfit]=best(newpop,fitvalue);%求出群体中适应值最小的个体及其适应值
       if bestfit<ymax
          ymax=bestfit;
           for j=1:N  %译码！
               temp(:,j)=decodechrom(bestindividual,1+(j-1)*length,length);      %将newpop每行(个体）每列（每段基因）转化成十进制数
               x(:,j)=temp(:,j)/(2^length-1)*(max(j)-min(j))+min(j);     % popsize×N 将二值域中的数转化为变量域的数      
           end
          ysw_x(i,:) = x;  %译码！
       end
       y(i,k)=ymax;
       if ymax<10     % 如果最大值小于设定阀值，停止进化
           break
       end
       pop=newpop;
   end  
end

ysw_x   % 结果为(i*popsie)个监测器（抗体）
plot(1:M,favg)