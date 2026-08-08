function evidence = extractEvidenceMetrics(maskEvidence)
%EXTRACTEVIDENCEMETRICS Compute simple, interpretable metrics from a mask.
%   EVIDENCE = EXTRACTEVIDENCEMETRICS(MASKEVIDENCE) returns a struct with:
%       numComponents - number of connected suspicious regions
%       maxArea       - area in pixels of the largest region (0 if none)
%       areaRatio     - fraction of the image flagged as suspicious
%       edgeDensity   - fraction of mask pixels lying on a region
%                       boundary; a cheap proxy for how jagged vs. blobby
%                       the suspicious regions are
%
%   This fixes two issues from the Live Script's "Interpretable Metrics"
%   section:
%     - bwconncomp(...) returns a struct (Connectivity, ImageSize,
%       NumObjects, PixelIdxList), not a count - the count is its
%       NumObjects field.
%     - regionprops(...,'Area') returns a struct array, one entry per
%       region, not a single "largest area" value - it needs max() over
%       [stats.Area].

    arguments
        maskEvidence (:,:) logical
    end

    cc = bwconncomp(maskEvidence);
    evidence.numComponents = cc.NumObjects;

    if cc.NumObjects > 0
        stats = regionprops(cc, 'Area');
        evidence.maxArea = max([stats.Area]);
    else
        evidence.maxArea = 0;
    end

    evidence.areaRatio = nnz(maskEvidence) / numel(maskEvidence);

    maskEdges = edge(maskEvidence, 'sobel');
    evidence.edgeDensity = nnz(maskEdges) / numel(maskEdges);
end
