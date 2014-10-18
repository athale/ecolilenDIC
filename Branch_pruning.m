%% Hemangi Chaudhari
%Athale Lab, IISER, Pune
% 22-04-2011
%%Aim : detection of branches : output one single skeleton
function[skeleton_pruned] = Branch_pruning(xy_coords);

MinX = min(xy_coords(:,1));
MinY = min(xy_coords(:,2));
MaxX = max(xy_coords(:,1));
MaxY = max(xy_coords(:,2));

C(:,1) = xy_coords(:,1) - MinX + 1;  % rescaled to reduce the image size
C(:,2) = xy_coords(:,2) - MinY + 1 ;

A = zeros(max(C(:,1)), max(C(:,2))); % image created...0 as background and 1 as skeleton

for i = 1 : length(C)
A(C(i, 1), C(i, 2)) = 1;
end
A1 = A;
[live,Adj_point_x,Adj_point_y] = adjacency_calc(A); % find the adjacent pixels in all 8 directions of a pixel
%% Find ends
B=ones(3); B(2,2)=0; % Count neighbors, not self
neigh = conv2(A,B,'same');% counts no. of neighbors around every  pixel
Result=neigh.*A; % gives values only for skeleton pixels
[x1,y1]  = find(Result ==1); % finds pixels connected to only one another pixel % only the first one is used as the start point

for no_branches = 1 : length(x1)
Skeleton{no_branches} = [x1(no_branches), y1(no_branches)]; % one skeleton created per end point.
Neighbor_skel = [];Angl = [];Neighbor =[];
end_point = 1; % variable to mark end of skeleton ; endpoint = 0 when end is reached
i = 1;
A = A1;
[live,Adj_point_x,Adj_point_y] = adjacency_calc(A);
%%

while end_point == 1
Neighbor  = find(live(Skeleton{no_branches}(i,1),Skeleton{no_branches}(i,2),:));  % find where the neighbors are
Angl = Neighbor;
if isempty(Neighbor) == true  % end of skeleton
    end_point = 0;
    break;
end

if length (Angl)>1   % more than one neighbor : BRANCH
   Avg_Angl = mean(Neighbor_skel);  % avg angle uptil this point, of the skeleton
   
for v = 1 : length(Angl)
   
     switch Angl( v)
 case {6}
 Angl( v) = -4;
  case {7}
  Angl( v) = -3;
  case {8}
  Angl( v) = -2;
    end
  
end 
   Neighbor(:,2) = abs( abs(Angl) - abs(Avg_Angl));  % Deviation of the current angles from the avg 
  
   
   Neighbor  = sortrows(Neighbor, 2);  % least distance is in the first row
   
   for k = 2 : length(Neighbor) % Remove all the other points from matrix A and recalculate the adjacency
   Next_point = [Skeleton{no_branches}(i,1)+ Adj_point_y(Skeleton{no_branches}(i,1),Skeleton{no_branches}(i,2),Neighbor(k,1)),Skeleton{no_branches}(i,2)+ Adj_point_x(Skeleton{no_branches}(i,1),Skeleton{no_branches}(i,2),Neighbor(k,1))]; 
    A(Next_point(1), Next_point(2)) = 0; 
    [live,Adj_point_x,Adj_point_y] = adjacency_calc(A);
   end
    Neighbor(2 :end,:) = []; % Removes other angles from the list
   
end

Next_point = [Skeleton{no_branches}(i,1)+ Adj_point_y(Skeleton{no_branches}(i,1),Skeleton{no_branches}(i,2),Neighbor(1,1)),Skeleton{no_branches}(i,2)+ Adj_point_x(Skeleton{no_branches}(i,1),Skeleton{no_branches}(i,2),Neighbor(1,1))]; 
switch Neighbor(1,1)
 case {5, 6 , 7, 8}
    Remove_angle = Neighbor(1,1) - 4;  
  case {1,2,3,4}
    Remove_angle = Neighbor(1,1) + 4;
end
    
live (Next_point(1), Next_point(2), Remove_angle) = 0; % Remove this angle from the next point, we have already considered this neighbor
Skeleton{no_branches} = [Skeleton{no_branches};Next_point]; % Next point is added to the skeleton
Neighbor_skel = [Neighbor_skel; Neighbor(1,1)];

    switch Neighbor_skel(end)
 case {6}
  Neighbor_skel(end) = -4;
  case {7}
  Neighbor_skel(end) = -3;
  case {8}
  Neighbor_skel(end) = -2;
    end
   
i = i +1;
end

%%
Sort_skel{no_branches}(:,1)  = Skeleton{no_branches}(:,1) + MinX -1; % Unscale to give original values.
Sort_skel{no_branches}(:,2)  = Skeleton{no_branches}(:,2) + MinY -1;
std_angle(no_branches, 2) = std(Neighbor_skel); % standard deviation of the angle
std_angle(no_branches, 1) = no_branches;
end
std_angle = sortrows(std_angle,2);  % object with the least standard deviation of angle selected as the skeleton
skeleton_pruned = Sort_skel{std_angle(1,1)};
end





