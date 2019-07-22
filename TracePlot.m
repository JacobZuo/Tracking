function [] = TracePlot(Trace_All)

    figure()
    hold on
    axis([0 2048 0 2048])
    axis equal
    box on
    set(gca, 'FontSize', 16, 'LineWidth', 1.5)
    LineTextColor = lines(size(Trace_All, 2));

    for i = 1:size(Trace_All, 2)
        plot(Trace_All{i}(:, 2), Trace_All{i}(:, 3), 'LineWidth', 1.5, 'color', LineTextColor(i, :))
        text(Trace_All{i}(floor(end / 2), 2), Trace_All{i}(floor(end / 2), 3), num2str(i), 'FontWeight', 'bold', 'FontSize', 16, 'color', LineTextColor(i, :))
    end

end
