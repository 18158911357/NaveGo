function  kf = kf_update(kf)
% kf_update: measurement update part of the Kalman filter algorithm.
%
% INPUT
%   kf, data structure with at least the following fields,
%       xi: nx1 a priori state vector.
%       Pi: nxn a priori error covariance matrix.
%        z: rx1 measurement vector.
%        H: rxn observation matrix.
%        R: rxr observation noise covariance matrix.
%
% OUTPUT
%    kf, the following fields are updated,
%       xp: nx1 a posteriori state vector (updated).
%       Pp: nxn a posteriori error covariance matrix (updated).
%		 v: rx1 innovation vector.
%        K: nxr Kalman gain matrix.
%        S: rxr innovation (not residual) covariance matrix.
%
%   Note: values of 'n' and 'r' depend on the number of available sensors.
%
%   Copyright (C) 2014, Rodrigo Gonzalez, all rights reserved.
%
%   This file is part of NaveGo, an open-source MATLAB toolbox for
%   simulation of integrated navigation systems.
%
%   NaveGo is free software: you can redistribute it and/or modify
%   it under the terms of the GNU Lesser General Public License (LGPL)
%   version 3 as published by the Free Software Foundation.
%
%   This program is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this program. If not, see
%   <http://www.gnu.org/licenses/>.
%
% Reference:
%
%   R. Gonzalez, J. Giribet, and H. Patiño. NaveGo: a
% simulation framework for low-cost integrated navigation systems,
% Journal of Control Engineering and Applied Informatics, vol. 17,
% issue 2, pp. 110-120, 2015. Alg. 1.
%
%   Dan Simon. Optimal State Estimation. Chapter 5. John Wiley
% & Sons. 2006.
%
% Version: 002
% Date:    2021/03/21
% Author:  Rodrigo Gonzalez <rodralez@frm.utn.edu.ar>
% URL:     https://github.com/rodralez/navego

% I = eye(size(kf.F));

% Step 3, update Kalman gain
kf.S = (kf.R + kf.H * kf.Pi * kf.H');			% Innovation covariance matrix
kf.v =  kf.z - kf.H * kf.xi; 					% Innovation vector

r = length(kf.v);
if rank (kf.S) < r
    error('kf_update: S innovation covariance matrix is not invertable.')
end

kf.K = (kf.Pi * kf.H') * (kf.S)^(-1) ;			% Kalman gain matrix

% Step 4, update the a posteriori state vector, xp
kf.xp = kf.xi + kf.K * kf.v;

% Step 5, update the a posteriori covariance matrix, Pp
kf.Pp = kf.Pi - kf.K * kf.S * kf.K';
% J = (I - S.K * S.H);                          % Joseph stabilized version
% S.Pp = J * S.Pi * J' + S.K * S.R * S.K';      % Alternative implementation
kf.Pp =  0.5 .* (kf.Pp + kf.Pp');               % Force Pp to be a symmetric matrix

end
