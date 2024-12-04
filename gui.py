from tkinter import *
import tkinter as tk
from tkinter import ttk


# root = Tk()

# root.title("Hospital")

# root.geometry('600x400')


# label = tk.Label(root, text='Welcome to CS310 Hospital!')
# label.pack()



#Pages

# Source: https://www.geeksforgeeks.org/tkinter-application-to-switch-between-different-page-frames/

LARGEFONT =("Verdana", 35)
  
class tkinterApp(tk.Tk):
     
    # __init__ function for class tkinterApp 
    def __init__(self, *args, **kwargs): 
         
        # __init__ function for class Tk
        tk.Tk.__init__(self, *args, **kwargs)

        #set title and geometry
        self.title("CS310 Hospital")
        self.geometry('1000x700')
         
        # creating a container
        container = tk.Frame(self)  
        container.pack(side = "top", fill = "both", expand = True) 
  
        container.grid_rowconfigure(0, weight = 1)
        container.grid_columnconfigure(0, weight = 1)
  
        # initializing frames to an empty array
        self.frames = {}  
  
        # iterating through a tuple consisting
        # of the different page layouts
        for F in (log_in, Employee_Front, Patient_Front):
  
            frame = F(container, self)
  
            # initializing frame of that object from
            # startpage, page1, page2 respectively with 
            # for loop
            self.frames[F] = frame 
  
            frame.grid(row = 0, column = 0, sticky ="nsew")
  
        self.show_frame(log_in)
  
    # to display the current frame passed as
    # parameter
    def show_frame(self, cont):
        frame = self.frames[cont]
        frame.tkraise()


class log_in(tk.Frame):
    def __init__(self, parent, controller):
        tk.Frame.__init__(self, parent)

        label = ttk.Label(self, text ="Welcome to CS310 Hospital", font = LARGEFONT)
        label.grid(row = 0, column = 4, padx = 10, pady = 10)
        # button to show frame 2 with text
        # layout2
        button1 = tk.Button(self, text ="Log In As Employee", width=15, height=10,
                            command = lambda : controller.show_frame(Employee_Front))
     
        # putting the button in its place by 
        # using grid
        button1.grid(row = 1, column = 1, padx = 10, pady = 10)
        button1.place(relx=0.4, rely=0.5, anchor=CENTER)

  
        ## button to show frame 2 with text layout2
        button2 = tk.Button(self, text ="Log In As Patient", width=15, height=10,
        command = lambda : controller.show_frame(Patient_Front))
     
        # putting the button in its place by
        # using grid
        button2.grid(row = 1, column = 2, padx = 10, pady = 10)
        button2.place(relx=0.6, rely=0.5, anchor=CENTER)


class Employee_Front(tk.Frame):
     
    def __init__(self, parent, controller):
         
        tk.Frame.__init__(self, parent)
        label = ttk.Label(self, text ="Employee Front Page", font = LARGEFONT)
        label.grid(row = 0, column = 4, padx = 10, pady = 10)
  
        # button to show frame 2 with text
        # layout2
        button1 = tk.Button(self, text ="Log In Page",
                            command = lambda : controller.show_frame(log_in))
     
        # putting the button in its place 
        # by using grid
        button1.grid(row = 1, column = 1, padx = 10, pady = 10)
  
        # button to show frame 2 with text
        # layout2
        button2 = tk.Button(self, text ="Patient Front Page",
                            command = lambda : controller.show_frame(Patient_Front))
     
        # putting the button in its place by 
        # using grid
        button2.grid(row = 2, column = 1, padx = 10, pady = 10)

        # Button to open a pop-up window
        pop_up_button = ttk.Button(self, text="Patient Check In", command=self.p_checkin)
        pop_up_button.grid(row=3, column=1, padx=10, pady=10)

    def p_checkin(self):
        # Create the Toplevel window (pop-up window)
        popup = tk.Toplevel(self)
        popup.title("Patient Check In")
        popup.geometry("500x400")

        # Add content to the pop-up window (label and button)
        label = ttk.Label(popup, text="Check In Patient")
        label.grid(row=0, column=2)

        pid_prompt = ttk.Label(popup, text="PID: ")
        pid_prompt.grid( row=1, column=1, padx=10, pady=10)
        pid_response = Entry(popup)
        pid_response.grid(row=1, column=2, padx=10,pady=10)

        checkin_prompt = ttk.Label(popup, text="Check In Day*: ")
        checkin_prompt.grid( row=2, column=1, padx=10, pady=10)
        checkin_response = Entry(popup)
        checkin_response.grid(row=2, column=2, padx=10,pady=10)

        checkin_prompt = ttk.Label(popup, text="Bed Type: ")
        checkin_prompt.grid( row=3, column=1, padx=10, pady=10)
        checkin_response = ttk.Combobox(popup, values=["Single", "Double"])
        checkin_response.grid(row=3, column=2, padx=10,pady=10)

        checkin_prompt = ttk.Label(popup, text="Bed: ")
        checkin_prompt.grid( row=4, column=1, padx=10, pady=10)
        checkin_response = ttk.Combobox(popup, values=["B1", "B2", "B3"])
        checkin_response.grid(row=4, column=2, padx=10,pady=10)

        # Submit button to process the input
        confirm_button = ttk.Button(popup, text="Confirm", command=popup.destroy)
        confirm_button.grid(row=5, column=2, padx=10, pady=10)


    #     close_button = ttk.Button(popup, text="Close", command=popup.destroy)
    #     close_button.pack(pady=20)


  
# third window frame page2
class Patient_Front(tk.Frame): 
    def __init__(self, parent, controller):
        tk.Frame.__init__(self, parent)
        label = ttk.Label(self, text ="Patient Front Page", font = LARGEFONT)
        label.grid(row = 0, column = 4, padx = 10, pady = 10)
  
        # button to show frame 2 with text
        # layout2
        button1 = tk.Button(self, text ="Employee Front Page",
                            command = lambda : controller.show_frame(Employee_Front))
     
        # putting the button in its place by 
        # using grid
        button1.grid(row = 1, column = 1, padx = 10, pady = 10)
  
        # button to show frame 3 with text
        # layout3
        button2 = tk.Button(self, text ="Log In",
                            command = lambda : controller.show_frame(log_in))
     
        # putting the button in its place by
        # using grid
        button2.grid(row = 2, column = 1, padx = 10, pady = 10)
  
# # Check In Patient
# class Check_In(tk.Frame): 
#     def __init__(self, parent, controller):
#         tk.Frame.__init__(self, parent)
#         label = ttk.Label(self, text ="Patient Front Page", font = LARGEFONT)
#         label.grid(row = 0, column = 4, padx = 10, pady = 10)
  
#         # button to show frame 2 with text
#         # layout2
#         button1 = ttk.Button(self, text ="Employee Front Page",
#                             command = lambda : controller.show_frame(Employee_Front))
     
#         # putting the button in its place by 
#         # using grid
#         button1.grid(row = 1, column = 1, padx = 10, pady = 10)
  
#         # button to show frame 3 with text
#         # layout3
#         button2 = ttk.Button(self, text ="Log In",
#                             command = lambda : controller.show_frame(log_in))
     
#         # putting the button in its place by
#         # using grid
#         button2.grid(row = 2, column = 1, padx = 10, pady = 10)






#Driver
app = tkinterApp()
app.mainloop()

# root.mainloop()



