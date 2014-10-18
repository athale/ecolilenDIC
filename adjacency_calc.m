%% Hemangi Chaudhari
%Athale Lab, IISER, Pune
% 22-04-2011
% Aim : Find out where the adjacent cells are located

function [live,Adj_point_x,Adj_point_y] = adjacency_calc(A);
%% Works for north-east
B=zeros(3); B(3,1)=1;
live(:,:,2)=conv2(A,B,'same').*A; Adj_point_x (:, :,2) =live(:,:,2)*1;Adj_point_y (:, :,2) =live(:,:,2)*-1;
%% Works for north-west
B=zeros(3); B(3,3)=1;
live(:,:,4)=conv2(A,B,'same').*A;Adj_point_x (:, :,4) =live(:,:,4)*-1;Adj_point_y (:, :,4) =live(:,:,4)*-1;
%% Works for east
B=zeros(3); B(2,1)=1;
live(:,:,1)=conv2(A,B,'same').*A; Adj_point_x (:, :,1) =live(:,:,1)*1;Adj_point_y (:, :,1) =live(:,:,1)*0;
%% Works for west
B=zeros(3); B(2,3)=1;
live(:,:,5)=conv2(A,B,'same').*A;Adj_point_x (:, :,5) =live(:,:,5)*-1;Adj_point_y (:, :,5) =live(:,:,5)*0;
%% Works for south
B=zeros(3); B(1,2)=1;
live(:,:,7)=conv2(A,B,'same').*A;Adj_point_x (:, :,7) =live(:,:,7)*0;Adj_point_y (:, :,7) =live(:,:,7)*1;
%% Works for north
B=zeros(3); B(3,2)=1;
live(:,:,3)=conv2(A,B,'same').*A;Adj_point_x (:, :,3) =live(:,:,3)*0;Adj_point_y (:, :,3) =live(:,:,3)*-1;
%% Works for south-west
B=zeros(3); B(1,3)=1;
live(:,:,6)=conv2(A,B,'same').*A;Adj_point_x (:, :,6) =live(:,:,6)*-1;Adj_point_y (:, :,6) =live(:,:,6)*1;
%% Works for south-east
B=zeros(3); B(1,1)=1;
live(:,:,8)=conv2(A,B,'same').*A;Adj_point_x (:, :,8) =live(:,:,8)*1;Adj_point_y (:, :,8) =live(:,:,8)*1;
end