function Z0 = prolong(CV,CT,CZ,V)
  [I] = in_element_aabb(CV,CT,V);
  I0 = find(I==0);

  switch size(CT,2)
  case 4
    [~,I(I0)] = point_mesh_squared_distance(V(I0,:),CV,boundary_faces(CT));
    [IV] = max(I,[],2);
    % recover barycentric coordinates
    B = barycentric_coordinates( ...
      V, ...
      CV(CT(IV,1),:),CV(CT(IV,2),:),CV(CT(IV,3),:),CV(CT(IV,4),:));
    Z0 = sum(bsxfun(@times, permute(B,[1 3 2]), ...
          cat(3, ...
            CZ(CT(IV,1),:), ...
            CZ(CT(IV,2),:), ...
            CZ(CT(IV,3),:), ...
            CZ(CT(IV,4),:))),3);
  case 3
    % Dirty trick to make V,CV 3D
    if ~isempty(I0)
      V(:,end+1:3) = 0;
      CV(:,end+1:3) = 0;
      [~,I(I0)] = point_mesh_squared_distance(V(I0,:),CV,CT);
    end
    [IV] = max(I,[],2);
    B = barycentric_coordinates( ...
      V, ...
      CV(CT(IV,1),:),CV(CT(IV,2),:),CV(CT(IV,3),:));
    Z0 = sum(bsxfun(@times, permute(B,[1 3 2]), ...
          cat(3, ...
            CZ(CT(IV,1),:), ...
            CZ(CT(IV,2),:), ...
            CZ(CT(IV,3),:))),3);
  end
end
