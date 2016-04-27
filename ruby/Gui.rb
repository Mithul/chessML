
include Java

import javax.swing.JButton
import javax.swing.JFrame
import javax.swing.JPanel
import java.awt.Color


class Gui < JFrame
    attr_accessor :used
  
    def initialize
        super "Tooltips"
        @buttons = []
        @used = false
        self.initUI
    end
    
    def initUI
      
        panel = JPanel.new
        self.getContentPane.add panel

        panel.setLayout nil 
        panel.setToolTipText "A Panel container"

        (0..7).each do |i|
          @buttons[i]=[]
          (0..7).each do |j|
            button = JButton.new "-"
            button.setBounds(i*50, j*50, 50,50)
            button.setToolTipText "A button component"
            # button.setBackground(Color.new(0,0,0))
            @buttons[i][j]=button
            panel.add button
          end
        end
        

        self.setDefaultCloseOperation JFrame::EXIT_ON_CLOSE
        self.setSize 450, 450
        self.setLocationRelativeTo nil
        self.setVisible true
    end

    def draw board
      # puts board
      (0..7).each do |i|
          (0..7).each do |j|
            piece = board[i*8 + j]
            # puts piece
            if piece != '-'
              # puts piece
              @buttons[i][j].setText piece.split('_')[1]
              if piece.split('_')[0] == 'W'
                @buttons[i][j].setBackground(Color.new(255,255,255))
              else
                @buttons[i][j].setBackground(Color.new(0,0,0))
              end
            else
              @buttons[i][j].setText '-'
              @buttons[i][j].setBackground(Color.new(100,100,100))
            end
          end
        end
    end
  
end

# Gui.new