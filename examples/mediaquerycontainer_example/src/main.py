import flet as ft

from mediaquerycontainer import MediaQueryContainer, MediaQueryContainerChangeEvent


def main(page: ft.Page):
    page.vertical_alignment = ft.MainAxisAlignment.CENTER
    page.horizontal_alignment = ft.CrossAxisAlignment.CENTER

    def size_change(event: MediaQueryContainerChangeEvent):
        print(event.window_width, event.window_height)

    page.add(
        MediaQueryContainer(
            height=150, 
            width=300, 
            alignment = ft.alignment.center, 
            bgcolor=ft.Colors.PURPLE_200, 
            content=ft.Text(
                tooltip="My new Mediaquerycontainer Control tooltip",
                value = "My new Mediaquerycontainer Flet Control", 
            ),
            on_media_query_change=size_change
        ),
    )


ft.app(main)
