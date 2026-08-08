function baselineDecision = decideRules(evidence, opts)
%DECIDERULES Simple, explainable defective/good baseline from evidence metrics.
%   BASELINEDECISION = DECIDERULES(EVIDENCE) applies two transparent
%   rules to the metrics produced by EXTRACTEVIDENCEMETRICS and returns
%   TRUE (flag as defective) if either fires:
%       - the largest suspicious region is bigger than AreaThreshold, or
%       - there are more suspicious regions than ComponentThreshold
%
%   BASELINEDECISION = DECIDERULES(EVIDENCE, 'AreaThreshold', A, ...
%       'ComponentThreshold', C) overrides the default thresholds.
%
%   Defaults below are from calibrateToothbrushThresholds.m, run against
%   40 known-good images: maxArea mean 53.8 / max 86.0, numComponents
%   mean 15.5 / max 32.0, each threshold set to 1.5x the worst normal
%   reading seen. Replaces the original 500/5 placeholders, which were
%   never checked against real data and were flagging 90.9% of good
%   toothbrushes as defective.

    arguments
        evidence (1,1) struct
        opts.AreaThreshold (1,1) double = 129
        opts.ComponentThreshold (1,1) double = 48
    end

    failsOnArea  = evidence.maxArea       > opts.AreaThreshold;
    failsOnCount = evidence.numComponents > opts.ComponentThreshold;

    baselineDecision = failsOnArea || failsOnCount;
end
