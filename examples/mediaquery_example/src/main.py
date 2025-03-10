import flet as ft

from mediaquery import MediaQuery


def main(page: ft.Page):
    page.vertical_alignment = ft.MainAxisAlignment.CENTER
    page.horizontal_alignment = ft.CrossAxisAlignment.CENTER

    def size_change(event: ft.ControlEvent):
        print(event.data)

    mediaquery = MediaQuery(
        content=ft.Text("HAHA"),
        on_size_change=size_change
    )

    page.add(
        mediaquery
    )


ft.app(main)
