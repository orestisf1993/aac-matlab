function X = deQuantize(S, a)
X = sign(S) .* (abs(S).^(4/3)) .* 2.^(1/4 * a);
end
