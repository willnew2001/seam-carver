clear;

color = double(imread('input.PNG'))/255;
image = rgb2gray(color);
    
v = VideoWriter("output.mp4", 'MPEG-4');
open(v);

% Seam carving loop %
for i=1:size(color,2)-1

    image = rgb2gray(color);

    % Compute gradients %
    [Gx, Gy] = imgradientxy(imgaussfilt(image(:,1:size(image,2)-(i-1)),2));
    
    % Compute overall magnitude %
    G = zeros(size(Gx));
    for rows=1:size(Gx,1)
        for cols=1:size(Gx,2)
            G(rows,cols) = sqrt(Gx(rows,cols)^2 + Gy(rows,cols)^2);
        end
    end
    
    % Fill cost matrix %
    C = zeros(size(G));
    C(1,:) = G(1,:);
    
    source_a = 0;
    source_b = 0;
    source_c = 0;
    for rows=2:size(G,1)
        for cols=1:size(G,2)
        
            if (cols == 1)
                source_a = Inf;
            else
                source_a = C(rows-1, cols-1);
            end
        
            source_b = C(rows-1, cols);
        
            if (cols == size(G,2))
                source_c = Inf;
            else
                source_c = C(rows-1, cols+1);
            end
        
            C(rows,cols) = G(rows, cols) + min([source_a source_b source_c]);
        end
    end

    
    % Find the optimal seam %
    seam = zeros(size(C,1),1);
    
    temp = find(C(size(C,1),:)==min(C(size(C,1),:)));
    seam(size(C,1)) = temp(1);
    
    for rows=size(C,1)-1:-1:1
        if (seam(rows+1) == 1)
            source_a = Inf;
        else
            source_a = C(rows,seam(rows+1)-1);
        end
    
        source_b = C(rows,seam(rows+1));
    
        if (seam(rows+1) == size(C,2))
            source_c = Inf;
        else
            source_c = C(rows,seam(rows+1)+1);
        end
        m = min([source_a source_b source_c]);
        if m == source_a
            seam(rows) = seam(rows+1)-1;
        elseif m == source_b
            seam(rows) = seam(rows+1);
        else
            seam(rows) = seam(rows+1)+1;
        end
    end
    
    % Superimpose the seam on the image %
    for rows=1:size(seam,1)
        color(rows,seam(rows),:) = [1 0 0];
    end
    
    % Write superimposed frame to video %
    writeVideo(v,color);
    
    % Delete seam and pad image %
    for rows=1:size(color,1)
        for cols=1:size(color,2)-1
            if cols >= seam(rows)
                for rgb=1:3
                    color(rows,cols,rgb) = color(rows,cols+1,rgb);
                end
            else
                for rgb=1:3
                    color(rows,cols,rgb) = color(rows,cols,rgb);
                end
            end
        end
        color(rows,size(color,2),:) = [0 0 0];
    end
end

% Write final 1-pixel wide frame to video %
writeVideo(v,color);

close(v);