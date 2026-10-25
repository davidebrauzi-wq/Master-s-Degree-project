% Function to plot the robot
function h = robot(p)
    x1 = p(1);
    y1 = p(2);
    x2 = p(3);
    y2 = p(4);
    pp1 = plot([x1 x2],[y1 y2],'b','LineWidth',1.5);
    hold on
    pp2 = plot([0 x1],[0 y1],'r','LineWidth',1.5);
    pp3 = plot(0,0,'o','MarkerSize',7,'MarkerFaceColor','k', ...
        'MarkerEdgeColor','k');
    pp4 = plot(x1,y1,'o','MarkerSize',7,'MarkerFaceColor','red', ...
        'MarkerEdgeColor','red');
    pp5 = plot(x2,y2,'o','MarkerSize',7,'MarkerFaceColor','blue', ...
        'MarkerEdgeColor','blue');

    h = [pp1 pp2 pp3 pp4 pp5];

end