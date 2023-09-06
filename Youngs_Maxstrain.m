data = DAQCrossheadTimed;

thickness_beam = 3.35; 
width_beam = 13.50; 
height_beam = 100; % mmXXXXXXXXXXXXXXXCHANGEXXXXXXXXXX
support_span = 107.2; 
loading_span = 53.6; 

% vectorized calculation
stresses = ((1.5* data.Load*1000) .* (support_span - loading_span)) ./ (width_beam * thickness_beam * thickness_beam);

maxstress = max(stresses);

% Calculate Peakload
Peakload = max(DAQCrossheadTimed.Load);
PeakloadNewtons = Peakload * 1000; 
fprintf('Peakload: %.2f N\n', PeakloadNewtons)

%calculate strain 
strains = (48 * data.Deflectometer * thickness_beam) ./ (11 * support_span^2 - ((support_span - loading_span)^2));
a = table(stresses, strains, 'VariableNames', {'StressMPA', 'Strain'}); 


% Define the lower and upper bounds for strain values
lower_bound = 0.001;
upper_bound = 0.003;

target_rows = a.Strain >= lower_bound & a.Strain < upper_bound;

target_stress_values = a.StressMPA(target_rows);
target_strain_values = a.Strain(target_rows);

% Least square fit Young's modulus
coefficients = polyfit(target_strain_values, target_stress_values, 1);
Youngs_modulus = coefficients(1);

% Display the results
fprintf('Young''s Modulus: %.2f GPa\n', Youngs_modulus / 1000); % Convert to GPa

fprintf('Maximum Stress: %.2f MPa\n', maxstress);
%-----------------------------------------------------

%plotting 
figure;
plot(a.Strain, a.StressMPA);
xlabel('Strain');
ylabel('Stress (MPa)');
title('Stress-Strain Curve');
grid on;

% Mark the peak load point
hold on;
plot(a.Strain(data.Load == Peakload), maxstress, 'ro', 'MarkerSize', 10);
legend('Stress-Strain', 'Peak Load', 'Location', 'Best');
hold off;


