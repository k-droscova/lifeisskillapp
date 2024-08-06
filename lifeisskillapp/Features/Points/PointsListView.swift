//
//  PointsListView.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 05.08.2024.
//

import SwiftUI

struct PointsListView: View {
    let points: [Point]
    let mapButtonAction: (Point) -> Void
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(points) { point in
                    PointListItem(point: point, mapButtonAction: {
                        mapButtonAction(point)
                    })
                }
            }
            .padding()
        }
    }
}

struct PointListItem: View {
    let point: Point
    let mapButtonAction: () -> Void
    
    var body: some View {
        PointListCard {
            contentView
                .background(point.type.color)
        }
    }
    
    private var contentView: some View {
        VStack {
            pointInfoView
            ExDivider(
                color: CustomColors.ListPointCard.foreground.color,
                width: PointListItemConstants.dividerHeight
            )
            mapIconView
        }
    }
    
    private var pointInfoView: some View {
        HStack {
            dateView
            Spacer()
            pointNameView
            Spacer()
            pointsView
        }
        .padding()
    }
    
    private var dateView: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(point.time.getTimeString())
            Text(point.time.getDayString())
            Text(point.time.getYearString())
        }
        .frame(width: PointListItemConstants.dateWidth, alignment: .leading)
        .foregroundStyle(CustomColors.ListPointCard.foreground.color)
        .body2Regular
    }
    
    private var pointNameView: some View {
        Text(point.name)
            .foregroundStyle(CustomColors.ListPointCard.foreground.color)
            .headline3
            .frame(maxWidth: .infinity, alignment: .center)
    }
    
    private var pointsView: some View {
        Text("\(point.value)")
            .headline2
            .foregroundColor(point.doesPointCount ? CustomColors.ListPointCard.foreground.color : CustomColors.ListPointCard.invalidPoint.color)
            .frame(width: PointListItemConstants.pointsWidth, alignment: .trailing)
    }
    
    private var mapIconView: some View {
        HStack {
            Spacer()
            Button(action: mapButtonAction) {
                Image(systemName: "map")
                    .resizable()
                    .squareFrame(size: PointListItemConstants.mapIconSize)
                    .foregroundStyle(CustomColors.ListPointCard.foreground.color)
                    .padding()
            }
        }
    }
    
    private enum PointListItemConstants {
        static let dateWidth: CGFloat = 40
        static let pointsWidth: CGFloat = 40
        static let mapIconSize: CGFloat = 20
        static let dividerHeight: CGFloat = 2.5
    }
}

struct PointsListView_Previews: PreviewProvider {
    static var previews: some View {
        PointsListView(points: [
            Point(id: "1", name: "Turistický bod AB123", value: 10, type: PointType.environment, doesPointCount: true),
            Point(id: "2", name: "Point 2", value: 20, type: PointType.culture, doesPointCount: false)
        ], mapButtonAction: { point in
            print("Map button pressed for point: \(point.name)")
        })
    }
}
