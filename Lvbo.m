clear
clc
% �����˲��õ����ǣ�
%     1.��ͨ�˲���2.��ͨ�˲���3.����ƽ���˲���
%  ���ݲ��õ����°������ɼ����ݣ�
%  ���ڣ�2018.01
% 
% PATH= 'P:\Matlabx\��������\WYL1-1.csv';  %����·��
PATH= 'S:\MIT����ļ�\MIT���ݲ�����\SamplePoint\Txt\100_1.txt';  %����·��
x=importdata(PATH);  %��������
x=x(:); %ȡǰ10000�������㣨����Ч���ã�
fs=360;
n = length (x);
n1=0:n-1;
t=0:1/fs:(n-1)/fs;
fx=fs*n1/n;   
X=fft(x,n);       %Fourier transform
X1=abs(X);
 
figure(1)
subplot(2,1,1);
plot(t,x);
title('ԭʼ�ź�');
xlabel('time/s');
ylabel('Amplitude');
subplot(2,1,2);
plot(fx(1:n/2),X1(1:n/2));
title(' ԭʼ�ź�Ƶ��ͼ ');
xlabel('Frequence/Hz');
ylabel('Amplitude');
axis([0 500 0 150000]); 
 
%% ***************�ú�������ƴ�ͨ�˲���******
ws1=2*pi*1/fs;
wp1=2*pi*2/fs;
wp2=2*pi*48/fs;
ws2=2*pi*49/fs;
wl=(ws1+wp1)/2;
wh=(wp2+ws2)/2;
delta_w=min((wp1-ws1),(ws2-wp2));
%delta_w=min((ws1-wp1),(ws2-wp2));
delta=0.001;
N=ceil((6.2*pi)/delta_w); 
l=0:N-1;
a=(N-1)/2;
m=l-a+eps;
hd=sin(wh*m)./(pi*m)-sin(wl*m)./(pi*m);
w=hanning(N);
h=hd.*w';
b=h;
[H,f]=freqz(b,1,512);
figure(3)
plot(f,20*log10(abs(H)))
xlabel('Ƶ��/Hz');ylabel('���/dB');grid on;
  
%��ͨ�˲�
a=1;
yb=filter(b,a,x);
YB=fft(yb,n);
YB1=abs(YB);
 
figure(4)
subplot(2,1,1);plot(t,yb);title('��ͨ�˲�����źŲ���');
xlabel('time/s');ylabel('Amplitude');%axis([0 35 -500 500]);
subplot(2,1,2);plot(fx(1:n/2),YB1(1:n/2));title('��ͨ�˲�����ź�Ƶ��');
xlabel('Frequence/Hz');ylabel('Amplitude');%axis([0 500 0 150000]);
%axis([0 2.5e4 0 600]);

%% ***************�˲������********************
x=yb; 
fp=40;   %ͨ����ֹƵ��
fss=47;  %�����ֹƵ��
%fs=250;
wp=2*pi*fp/fs;
ws=2*pi*fss/fs;
wap=tan(wp/2);was=tan(ws/2);
Rp=1;
Rs=10;
%eps=sqrt(10^(Rp/10)-1);%%ͨ����������
% Ripple=sqrt(1/(1+ep*ep))%ͨ������
% Attn=1/(10^(Rs/20))%���˥��
[N,Wn]=buttord(wap,was,Rp,Rs,'s');%j�������N���ͽ�ֹƵ��
[z,p,k]=buttap(N);%��ƹ�һ���İ�����˹ģ��ԭ���˲���
[bp,ap]=zp2tf(z,p,k);%ϵͳ�����㼫��ת��ϵͳ��������ʽϵ��
[bs,as]=lp2lp(bp,ap,wap);%�任Ϊģ���ͨ�˲���
[bz,az]=bilinear(bs,as,1/2);    %˫���Ա任�������˲���ϵ��
[H,w]=freqz(bz,az,250,fs);
dbH=20*log10((abs(H)+eps)/max(abs(H)));

%**********���˲���������ͼ***************
figure(5)
subplot(2,2,1),plot(w,abs(H));grid;
title('Magnitude Response');
xlabel('Frequence(Hz)');ylabel('Magnitude');%axis([0 6000 0 1.2])
subplot(2,2,2),plot(w,angle(H)/pi);grid;
title('Phase Response');
xlabel('Frequence(Hz)');ylabel('Phase');
subplot(2,2,3),plot(w,dbH);grid;
title('Magnitude Response(dB)');
xlabel('Frequence(Hz)');ylabel('Magnitude/dB');

%% ***************��ͨ�˲�**********************
y=filter(bz,az,x);%�˲�
Y=fft(y,n);
Y1=abs(Y);

%**********������ͨ�˲����ͼ��**********
figure(6)
subplot(2,1,1);plot(t,y);title('��ͨ�˲�����ź�');grid;
xlabel('Time(s)');ylabel('Magnitude');%axis([0 16 2500 4000]);
subplot(2,1,2);plot(fx(1:n/2),Y1(1:n/2));title('��ͨ�˲����Ƶ��ͼ');grid;
xlabel('Frequency(Hz)');ylabel('Magnitude');axis([0 500 0 150000]);

%% ***************����ƽ���˲�*****************

    nd=length(y);
%     figure
%      plot(t,y,'r');%����ԭʼ����
%      grid
%      hold on

     col_array=nd;   %�ܹ���ɢ��ĸ���
     data_array_section=ones(1,col_array);
     for k=1:col_array
          data_array_section(k)=y(k);  %��ȡ����650��������������data_array_section��
     end

     moving_point=7;      %?����moving average��ȥ���ٸ������ƽ�����㣬Ҳ����M��ֵ������Ϊ����;�ȽϺ����ֵ9
     moving_point_left=(-moving_point+1)/2;  
     moving_point_right=(moving_point-1)/2;  %ȡ�����Գ����ߵĲ������ֵ��ƽ��
     data_array_filter=zeros(1,col_array);   %��ʼ��һ����data_array_section��С��ͬ�ľ��󣬴洢���
 
     for i=1:moving_point_right
          data_array_filter(i)=data_array_section(i);  
     end

     for i=(col_array+moving_point_left+1):col_array  
          data_array_filter(i)=data_array_section(i);
     end  %��һ�δ��룬�ǶԾ����ǰ(M-1)/2���ͺ�(M-1)/2������и�ֵ,��Ϊ��Щǰ�ںͺ��ڵĵ㣬�޷����㷨����                    

     for i=(moving_point_right+1):(col_array+moving_point_left)  %i�ķ�ΧΪҪ���µ������±귶Χ
          for j=moving_point_left:moving_point_right
               data_array_filter(i)=data_array_filter(i)+data_array_section(i+j);  %moving average filter process
          end
     data_array_filter(i)=data_array_filter(i)/moving_point;
     end
     figure(7)
     subplot(2,1,1);plot(t,data_array_filter);title('����ƽ���˲�����ź�');grid;%axis([0 16 2500 4000]);%�����˲��������
     %hold off
     %axis([0,10,-400,400]);
    % legend('bf�������ź�','bf��hp�������ź�');
%      saveas(gca,[path_in,num2str(ki)],'fig');
%      close
%      yy=data_array_filter;
%      [my,ny]=size(yy);
%      Nzbfhd(count,1:ny)=yy(1,1:ny);
%          
%      count=count+1;
%      clear t data_array data_array_filter y;